class MarkupCloud
  def initialize(markups = nil)
    @markups = markups
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
    markups[compile_pattern(pattern)] = block
  end

  def remote_markup(pattern, address)
    markups[compile_pattern(pattern)] = RemoteMarkup.new(address)
  end

  def renderable?(filename)
    !! renderer_for(filename)
  end

  def renderer_for(filename)
    markups.each do |pattern, endpoint|
      return endpoint if filename =~ pattern
    end
    nil
  end

  def markups
    @markups ||= {}
  end

  def compile_pattern(pattern)
    Regexp.compile("\\.(#{pattern})$")
  end

  class RemoteMarkup
    def initialize(address)
      @address = address
      reset
    end

    def call(content)
      @socket.send_string content
      @socket.recv_string html=''
      html.empty? ? content : html
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

