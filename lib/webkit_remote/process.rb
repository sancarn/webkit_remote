require 'fileutils'
require 'net/http'
require 'posix/spawn'
require 'tmpdir'

module WebkitRemote

# Tracks a Webkit process.
class Process
  # Tracker for a yet-unlaunched process.
  #
  # @param [Hash] opts tweak the options below
  # @option opts [Integer] port the port used by the remote debugging server;
  #     the default port is 9292
  # @option opts [Number] timeout number of seconds to wait for the browser
  #     to start; the default timeout is 10 seconds
  # @option opts [Hash<Symbol, Number>] window set the :left, :top, :width and
  #     :height of the browser window; by default, the browser window is
  #     256x256 starting at 0,0.
  # @option opts [Hash<Symbol, Number>, Boolean] xvfb use Xvfb instead of a
  #     real screen; set the :display, :width, :height, :depth and :dpi of the
  #     server, or use the default display number 20, at 1280x1024x32 with
  #     72dpi
  def initialize(opts = {})
    @port = opts[:port] || 9292
    @timeout = opts[:timeout] || 10
    @running = false
    @data_dir = Dir.mktmpdir 'webkit-remote'
    @pid = nil
    @cli = chrome_cli opts
  end

  # Starts the browser process.
  #
  # @return [WebkitRemote::Browser] self
  def start
    return self if running?
    unless @pid = POSIX::Spawn.spawn(*@cli)
      # The launch failed
      return nil
    end

    (@timeout * 20).times do
      # Check if the browser exited.
      begin
        break if status = ::Process.wait(@pid, ::Process::WNOHANG)
      rescue SystemCallError  # no children
        break
      end

      # Check if the browser finished starting up.
      begin
        browser = WebkitRemote::Browser.new process: self
        @running = true
        return browser
      rescue SystemCallError  # most likely ECONNREFUSED
        Kernel.sleep 0.05
      end
    end
    # The browser failed, or was too slow to start.
    nil
  end

  # @return [Boolean] true if the Webkit process is running
  attr_reader :running
  alias_method :running?, :running

  # Stops the browser process.
  #
  # Only call this after you're done with the process.
  #
  # @return [WebkitRemote::Process] self
  def stop
    return self unless running?
    begin
      ::Process.kill 'TERM', @pid
      ::Process.wait @pid
    end
    FileUtils.rm_rf @data_dir if File.exists?(@data_dir)
    @running = false
    self
  end

  # @return [Integer] port that the process' remote debugging server listens to
  attr_reader :port

  # Remove temporary directory if it's still there at garbage collection time.
  def finalize
    PathUtils.rm_rf @data_dir if File.exists?(@data_dir)
  end

  # Command-line that launches Google Chrome / Chromium
  #
  # @param [Hash] opts options passed to the WebkitRemote::Process constructor
  # @return [Array<String>] command line for launching Chrome
  def chrome_cli(opts)
    # The Chromium wiki recommends this page for available flags:
    #     http://peter.sh/experiments/chromium-command-line-switches/
    [
      self.class.chrome_binary,
      '--disable-default-apps',  # no bundled apps
      '--disable-desktop-shortcuts',  # don't mess with the desktop
      '--disable-extensions',  # no extensions
      '--disable-internal-flash',  # no plugins
      '--disable-java',  # no plugins
      '--disable-logging',  # don't trash stdout / stderr
      '--disable-plugins',  # no native content
      '--disable-prompt-on-repost',   # no confirmation dialog on POST refresh
      '--disable-sync',  # no talking with the Google servers
      '--incognito',  # don't use old state, don't preserve state
      '--homepage=about:blank',  # don't go to Google in new tabs
      '--keep-alive-for-test',  # don't kill process if the last window dies
      '--lang=en-US',  # set a default language
      '--log-level=3',  # FATAL, because there's no setting for "none"
      '--no-default-browser-check',  # don't hang when Chrome isn't default
      '--no-experiments',  # not sure this is useful
      '--no-first-run',  # don't show the help UI
      '--no-js-randomness',  # consistent Date.now() and Math.random()
      '--no-message-box',  # don't let user scripts show dialogs
      '--no-service-autorun',  # don't mess with autorun settings
      '--noerrdialogs',  # don't hang on error dialogs
      "--remote-debugging-port=#{@port}",  # Webkit remote debugging
      "--user-data-dir=#{@data_dir}",  # really ensure a clean slate
      '--window-position=0,0',  # remove randomness source
      '--window-size=128,128',  # remove randomness source
      'about:blank',  # don't load the homepage
      {
        chdir: @data_dir,
        in: '/dev/null',
        out: File.join(@data_dir, '.stdout'),
        err: File.join(@data_dir, '.stderr'),
      },
    ]
  end

  # Command-line that launchex Xvfb
  def xvfb_cli(opts)
    # The OSX man page for Xvfb:
    #     http://developer.apple.com/library/mac/documentation/darwin/reference/manpages/man1/Xvfb.1.html

    xvfb_opts = opts[:xvfb]
    unless xvfb_opts.respond_to? :[]
      xvfb_opts = {}
    end

    display = xvfb_opts[:display] || 20
    width = xvfb_opts[:width] || 1280
    height = xvfb_opts[:height] || 1024
    depth = xvfb_opts[:depth] || 32
    dpi = xvfb_opts[:dpi] || 72
    [
      self.class.xvfb_binary,
      ":#{display}",
      "-screen 0 #{width}x#{height}x#{depth}",
      "-auth #{File.join(@data_dir, '.Xauthority')}",
      '-c',
      "-dpi #{dpi}",
      '-terminate',
      '-wr',
      {
        chdir: @data_dir,
        in: '/dev/null',
        out: File.join(@data_dir, '.X_stdout'),
        err: File.join(@data_dir, '.X_stderr'),
      },
    ]
  end

  # Path to a Google Chrome / Chromium binary.
  #
  # @return [String] full-qualified path to a binary that launches Chrome
  def self.chrome_binary
    return @chrome_binary unless @chrome_binary == false

    case RUBY_PLATFORM
    when /linux/
      [
        'google-chrome',
        'google-chromium',
      ].each do |binary|
        path = `which #{binary}`
        unless path.empty?
          @chrome_binary = path.strip
          break
        end
      end
    when /darwin/
      [
        '/Applications/Chromium.app/Contents/MacOS/Chromium',
        '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
        '/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary',
      ].each do |path|
        if File.exist? path
          @chrome_binary = path
          break
        end
      end
    else
      raise "Unsupported platform #{RUBY_PLATFORM}"
    end
    @chrome_binary ||= nil
  end
  @chrome_binary = false

  # Path to the Xvfb virtual X server binary.
  #
  # @return [String] full-qualified path to a binary that launches Xvfb.
  def self.xvfb_binary
    return @xvfb_binary unless @xvfb_binary == false

    path = `which Xvfb`
    unless path.empty?
      @xvfb_binary = path.strip
    end
    @xvfb_binary = nil
  end
  @xvfb_binary = false
end  # class WebkitRemote::Browser

end  # namespace WebkitRemote
