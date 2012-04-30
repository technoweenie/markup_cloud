class MarkupCloud
  def initialize
    @markups = {}
    @remote_markups = {}
  end

  # Public: Renders the content with the markup renderer selected by the given
  # filename.
  #
  # filename - The String name of the file to render.  This determines which
  #            markup renderer to use.
  # content  - The UTF-8 String that is being rendered.
  #
  # Returns the rendered String.
  def render(filename, content)
    if renderer = renderer_for(filename)
      renderer.call content
    else
      content
    end
  end

  # Public: Adds a local markup renderer to this MarkupCloud.  If the renderer
  # depends on a library, it can be loaded.
  #
  # pattern - String or Regexp pattern that should match a file extension given
  #           to #render.
  # lib     - Optional String name of a ruby library dependency.
  # &block  - The Block that is called with the content to render.
  #
  # Returns the Block, or false if the lib dependency is not met.
  def local_markup(pattern, lib = nil, &block)
    require lib.to_s if lib
    @markups[compile_pattern(pattern)] = block
  rescue LoadError
    false
  end

  # Public: Adds a remote renderer that sends to and receives the marked up
  # content from a ZeroMQ REQ socket.
  #
  # pattern - String or Regexp pattern that should match a file extension given
  #           to #render.
  # address - The String address of the ZeroMQ REP socket server.
  # name    - Optional String name of the service.  This allows a single ZeroMQ
  #           process to handle multiple markup formats.
  #
  # Returns a NamedMarkup object.
  def remote_markup(pattern, address, name = nil)
    remote = @remote_markups[address] ||= RemoteMarkup.new(address)
    @markups[compile_pattern(pattern)] = remote.named(name || :markup)
  end

  # Public: Finds the renderer for a file by checking for a pattern match.
  #
  # filename - The String name of the file to render.
  #
  # Returns the renderer (either a Block or NamedMarkup).
  def renderer_for(filename)
    @markups.each do |pattern, endpoint|
      return endpoint if filename =~ pattern
    end
    nil
  end

  # Compiles the pattern to a Regexp.
  #
  # pattern - String or Regexp pattern that should match a file extension given
  #           to #render.
  #
  # Returns the compiled Regexp.
  def compile_pattern(pattern)
    Regexp.compile("\\.(#{pattern})$")
  end

  # Responsible for calling a markup renderer through a remote ZeroMQ REP
  # socket.  This is what the MarkupCloud uses to render content.
  class NamedMarkup

    # remote - A RemoteMarkup object.
    # name    - Optional String name of the service.  This allows a single
    #           ZeroMQ process to handle multiple markup formats.
    def initialize(remote, name)
      @remote = remote
      @name = name.to_s
    end

    # Public: Calls the RemoteMarkup instance.
    #
    # content  - The UTF-8 String that is being rendered.
    #
    # Returns the rendered String.
    def call(content)
      @remote.call @name, content
    end
  end

  # Sends data between the MarkupCloud object and a remote ZeroMQ REP socket.
  class RemoteMarkup

    # address - The String address of the ZeroMQ REP socket server.
    def initialize(address)
      @address = address
      reset
    end

    # Public: Sends the name and content to the remote ZeroMQ REP server socket.
    #
    # name     - Optional String name of the service.
    # content  - The UTF-8 String that is being rendered.
    #
    # Returns the rendered String.
    def call(name, content)
      @socket.send_strings [name, content]
      @socket.recv_string html=''
      html.empty? ? content : html
    end

    # Public: Creates a NamedMarkup for this RemoteMarkup object and the given
    # name.
    #
    # name     - Optional String name of the service.
    #
    # Returns a NamedMarkup
    def named(name)
      NamedMarkup.new self, name
    end

    # Resets the ZeroMQ REQ client socket.
    #
    # Returns nothing.
    def reset
      @socket = self.class.context { |c| c.socket(ZMQ::REQ) }
      @socket.connect @address
    end

    class << self
      attr_writer :context

      # Contains a reference to the single ZeroMQ Context for this process.
      #
      # Returns a ZMQ::Context.
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

