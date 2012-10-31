module WebkitRemote

class Event

# Emitted when a console message is produced.
class ConsoleMessage < WebkitRemote::Event
  register 'Console.messageAdded'

  # @return [String] the message text
  attr_reader :text

  # @return [Array<WebkitRemote::Client::RemoteObject>] extra arguments given
  #     to the message
  attr_reader :params

  # @return [Symbol] message severity
  #
  # The documented values are :debug, :error, :log, :tip, and :warning.
  attr_reader :level

  # @return [Integer] how many times this message was repeated
  attr_reader :count

  # @return [Symbol] the component that produced this message
  #
  # The documented values are :console_api, :html, :javascript, :network,
  #     :other, :wml, and :xml.
  attr_reader :reason

  # @return [Symbol] the behavior that produced this message
  #
  # The documented values are :assert, :dir, :dirxml, :endGroup, :log,
  #     :startGroup, :startGroupCollapsed, and :trace.
  attr_reader :type

  # @return [String] the URL of the file that caused this message
  attr_reader :source_url

  # @return [Integer] the line number of the statement that caused this message
  attr_reader :source_line

  # @return [Array<Hash<Symbol, Object>>] JavaScript stack trace to the
  #     statement that caused this message
  attr_reader :stack_trace

  # @private Use Event#for instead of calling this constructor directly.
  def initialize(rpc_event, client)
    super

    if raw_message = raw_data['message']
      @level = (raw_message['level'] || 'error').to_sym
      @source_line = raw_message['line'] ? raw_message['line'].to_i : nil
      # TODO(pwnall): parse networkRequestId when Network is implemented
      if raw_message['parameters']
        @params = raw_message['parameters'].map do |raw_object|
          WebkitRemote::Client::RemoteObject.for raw_object, client, nil
        end
      else
        @params = []
      end
      @params.freeze
      @count = raw_message['repeatCount'] ? raw_message['repeatCount'].to_i : 1
      if raw_message['source']
        @reason = raw_message['source'].gsub('-', '_').to_sym
      else
        @reason = :other
      end
      if raw_message['stackTrace']
        @stack_trace = raw_message['stackTrace'].map do |raw_frame|
          frame = {}
          if raw_frame['columnNumber']
            frame[:column] = raw_frame['columnNumber'].to_i
          end
          if raw_frame['lineNumber']
            frame[:line] = raw_frame['lineNumber'].to_i
          end
          if raw_frame['functionName']
            frame[:function] = raw_frame['functionName']
          end
          if raw_frame['url']
            frame[:url] = raw_frame['url']
          end
          frame
        end
      else
        @trace = nil
      end
      @text = raw_message['text']
      @type = raw_message['type'] ? raw_message['type'].to_sym : nil
      @source_url = raw_message['url']
    end

    # NOTE(pwnall): if the client will keep track of console messages, this is
    #     the right place to call into the client and register the message
  end

  # Releases the JavaScript objects referenced by this message's parameters.
  def release_params()
    @params.each do |param|
      if param.kind_of?(WebkitRemote::Client::RemoteObject)
        param.release
      end
    end
  end

  # @private Use Event#can_receive instead of calling this directly.
  def self.can_reach?(client)
    client.console_events
  end
end  # class WebkitRemote::Event::ConsoleMessage

# Emitted when the same console message is produced repeatedly.
class ConsoleMessageRepeated < WebkitRemote::Event
  register 'Console.messageRepeatCountUpdated'

  # @return [Number] the number of times that the message was repeated
  attr_reader :count

  # @private Use Event#for instead of calling this constructor directly.
  def initialize(rpc_event, client)
    super
    @count = raw_data['count'] ? raw_data['count'].to_i : nil

    # NOTE(pwnall): if the client will keep track of console messages, this is
    #     the right place to call into the client and have it update the repeat
    #     count of the most recent message that it received
  end

  # @private Use Event#can_receive instead of calling this directly.
  def self.can_reach?(client)
    client.console_events
  end
end  # class WebkitRemote::Event::ConsoleMessageRepeated

# Emitted when the console is cleared.
class ConsoleCleared < WebkitRemote::Event
  register 'Console.messagesCleared'

  # @private Use Event#for instead of calling this constructor directly.
  def initialize(rpc_event, client)
    super

    # NOTE(pwnall): if the client will keep track of console messages, this is
    #     the right place to call into the client and have it wipe its message
    #     list, and call #release_params on the messages
  end

  # @private Use Event#can_receive instead of calling this directly.
  def self.can_reach?(client)
    client.console_events
  end
end  # class WebkitRemote::Event::ConsoleCleared

end  # namespace WebkitRemote::Event

end  # namepspace WebkitRemote
