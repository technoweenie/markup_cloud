require "rdoc"
require "rdoc/markup/to_html"

class MarkupCloud
  class RDoc
    def initialize(content)
      @content = content
    end

    def to_html
      h = ::RDoc::Markup::ToHtml.new
      h.convert(@content)
    end
  end
end

