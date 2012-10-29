# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "webkit_remote"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Victor Costan"]
  s.date = "2012-10-29"
  s.description = "Launches Google Chrome instances and controls them via the Remote Debugging server"
  s.email = "victor@costan.us"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/webkit_remote.rb",
    "lib/webkit_remote/browser.rb",
    "lib/webkit_remote/client.rb",
    "lib/webkit_remote/client/page.rb",
    "lib/webkit_remote/client/page_events.rb",
    "lib/webkit_remote/client/runtime.rb",
    "lib/webkit_remote/event.rb",
    "lib/webkit_remote/process.rb",
    "lib/webkit_remote/rpc.rb",
    "lib/webkit_remote/top_level.rb",
    "test/fixtures/config.ru",
    "test/fixtures/html/load.html",
    "test/fixtures/html/runtime.html",
    "test/helper.rb",
    "test/webkit_remote/browser_test.rb",
    "test/webkit_remote/client/page_test.rb",
    "test/webkit_remote/client/remote_object_group_test.rb",
    "test/webkit_remote/client/remote_object_test.rb",
    "test/webkit_remote/client/runtime_test.rb",
    "test/webkit_remote/client_test.rb",
    "test/webkit_remote/event_test.rb",
    "test/webkit_remote/process_test.rb",
    "test/webkit_remote/rpc_test.rb",
    "test/webkit_remote_test.rb"
  ]
  s.homepage = "http://github.com/pwnall/webkit_remote"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Client for the Webkit Remote Debugging server"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<faye-websocket>, [">= 0.4.6"])
      s.add_runtime_dependency(%q<posix-spawn>, [">= 0.3.6"])
      s.add_development_dependency(%q<bundler>, [">= 1.2.1"])
      s.add_development_dependency(%q<jeweler>, [">= 1.8.4"])
      s.add_development_dependency(%q<minitest>, [">= 4.1.0"])
      s.add_development_dependency(%q<puma>, [">= 1.6.3"])
      s.add_development_dependency(%q<rack>, [">= 1.4.1"])
      s.add_development_dependency(%q<rdoc>, [">= 3.12"])
      s.add_development_dependency(%q<ruby-prof>, [">= 0.11.2"])
      s.add_development_dependency(%q<simplecov>, [">= 0.7.1"])
      s.add_development_dependency(%q<yard>, [">= 0.8.3"])
    else
      s.add_dependency(%q<eventmachine>, [">= 1.0.0"])
      s.add_dependency(%q<faye-websocket>, [">= 0.4.6"])
      s.add_dependency(%q<posix-spawn>, [">= 0.3.6"])
      s.add_dependency(%q<bundler>, [">= 1.2.1"])
      s.add_dependency(%q<jeweler>, [">= 1.8.4"])
      s.add_dependency(%q<minitest>, [">= 4.1.0"])
      s.add_dependency(%q<puma>, [">= 1.6.3"])
      s.add_dependency(%q<rack>, [">= 1.4.1"])
      s.add_dependency(%q<rdoc>, [">= 3.12"])
      s.add_dependency(%q<ruby-prof>, [">= 0.11.2"])
      s.add_dependency(%q<simplecov>, [">= 0.7.1"])
      s.add_dependency(%q<yard>, [">= 0.8.3"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 1.0.0"])
    s.add_dependency(%q<faye-websocket>, [">= 0.4.6"])
    s.add_dependency(%q<posix-spawn>, [">= 0.3.6"])
    s.add_dependency(%q<bundler>, [">= 1.2.1"])
    s.add_dependency(%q<jeweler>, [">= 1.8.4"])
    s.add_dependency(%q<minitest>, [">= 4.1.0"])
    s.add_dependency(%q<puma>, [">= 1.6.3"])
    s.add_dependency(%q<rack>, [">= 1.4.1"])
    s.add_dependency(%q<rdoc>, [">= 3.12"])
    s.add_dependency(%q<ruby-prof>, [">= 0.11.2"])
    s.add_dependency(%q<simplecov>, [">= 0.7.1"])
    s.add_dependency(%q<yard>, [">= 0.8.3"])
  end
end

