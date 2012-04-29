require 'test/unit'
require File.expand_path("../../lib/markup_cloud", __FILE__)

class MarkupCloudServerTest < Test::Unit::TestCase
  def setup
    @cloud = MarkupCloud.new
  end

  def test_empty_cloud
    assert_equal 'def', @cloud.render('abc', 'def')
  end

  def test_local_markup_without_dependency
    @cloud.local_markup :q do |content|
      content + '?'
    end

    assert_equal 'sup?', @cloud.render('serious.q', 'sup')
  end
end
