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

  def renderer_for(filename)
    markups.each do |pattern, endpoint|
      return endpoint if filename =~ pattern
    end
    nil
  end

  def local_markup(pattern, file = nil, &block)
    require file if file
    markups[compile_pattern(pattern)] = block
  end

  def markups
    @markups ||= {}
  end

  def compile_pattern(pattern)
    Regexp.compile("\\.(#{pattern})$")
  end
end
