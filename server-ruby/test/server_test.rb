require 'test/unit'
require File.expand_path("../../lib/markup_cloud", __FILE__)

class MarkupCloudServerTest < Test::Unit::TestCase
  def test_empty_cloud
    cloud = MarkupCloud.new
    assert_equal 'def', cloud.render('abc', 'def')
  end
end
