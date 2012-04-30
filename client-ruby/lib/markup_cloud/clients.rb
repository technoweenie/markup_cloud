require File.expand_path("../../markup_cloud", __FILE__)

class MarkupCloud
  MD_FILES = /md|mkdn?|mdown|markdown/

  def setup_local_clients!
    if local_markup(MD_FILES, 'github/markdown') do |content|
        GitHub::Markdown.render(content)
      end
    elsif local_markup(MD_FILES, :redcarpet) do |content|
        RedcarpetCompat.new(content).to_html
      end 
    elsif local_markup(MD_FILES, :rdiscount) do |content|
        RDiscount.new(content).to_html
      end 
    elsif local_markup(MD_FILES, :maruku) do |content|
        Maruku.new(content).to_html
      end 
    elsif local_markup(MD_FILES, :kramdown) do |content|
        Kramdown::Document.new(content).to_html
      end
    elsif local_markup(MD_FILES, :bluecloth) do |content|
        BlueCloth.new(content).to_html
      end
    end

    local_markup(/textile/, :redcloth) do |content|
      RedCloth.new(content).to_html
    end

    local_markup(/rdoc/, File.expand_path('../rdoc', __FILE__)) do |content|
      MarkupCloud::RDoc.new(content).to_html
    end

    local_markup(/org/, 'org-ruby') do |content|
      Orgmode::Parser.new(content).to_html
    end

    local_markup(/creole/, :creole) do |content|
      Creole.creolize(content)
    end

    local_markup(/mediawiki|wiki/, :wikicloth) do |content|
      WikiCloth::WikiCloth.new(:data => content).to_html(:noedit => true)
    end
  end
end

