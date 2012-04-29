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
      if Regexp.compile("\\.(#{pattern})$") =~ filename
        return endpoint
      end
    end
    nil
  end

  def markups
    @markups ||= {}
  end
end
