class MarkupCloud
  def initialize
    @markups = {}
    @remote_markups = {}
  end

  def render(filename, content)
    if renderer = renderer_for(filename)
      renderer.call content
    else
      content
    end
  end

  def local_markup(pattern, file = nil, &block)
    require file if file
    @markups[compile_pattern(pattern)] = block
  end

  def remote_markup(pattern, address, name = nil)
    remote = @remote_markups[address] ||= RemoteMarkup.new(address)
    @markups[compile_pattern(pattern)] = remote.named(name || :markup)
  end

  def renderer_for(filename)
    @markups.each do |pattern, endpoint|
      return endpoint if filename =~ pattern
    end
    nil
  end

  def compile_pattern(pattern)
    Regexp.compile("\\.(#{pattern})$")
  end

  class RemoteMarkup
    class NamedMarkup
      def initialize(remote, name)
        @remote = remote
        @name = name.to_s
      end

      def call(content)
        @remote.call @name, content
      end
    end

    def initialize(address)
      @address = address
      reset
    end

    def call(name, content)
      @socket.send_strings [name, content]
      @socket.recv_string html=''
      html.empty? ? content : html
    end

    def named(name)
      NamedMarkup.new self, name
    end

    def reset
      @socket = self.class.context { |c| c.socket(ZMQ::REQ) }
      @socket.connect @address
    end

    class << self
      attr_writer :context

      def context
        @context ||= begin
          require 'ffi-rzmq'
          ZMQ::Context.new
        end
        block_given? ? yield(@context) : @context
      end
    end
  end
end

