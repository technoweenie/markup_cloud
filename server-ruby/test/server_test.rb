require 'test/unit'
require 'thread'
require File.expand_path("../../lib/markup_cloud", __FILE__)

class MarkupCloudServerTest < Test::Unit::TestCase
  def setup
    @cloud = MarkupCloud.new
    @context = MarkupCloud::RemoteMarkup.context
    @threads = []
  end

  def test_empty_cloud
    assert_equal 'def', @cloud.render('abc', 'def')
  end

  def test_remote_markup
    addr = 'inproc://remote-markup'

    rep = @context.socket ZMQ::REP
    rep.bind addr
    @cloud.remote_markup :zmq, addr

    Thread.new do
      rep.recv_string msg = ''
      assert_equal 'abc', msg
      rep.send_string 'zmq'
      rep.close
    end

    assert_equal 'zmq', @cloud.render('foo.zmq', 'abc')
  end

  def test_local_markup_without_dependency
    @cloud.local_markup :q do |content|
      content + '?'
    end

    assert_equal 'sup?', @cloud.render('serious.q', 'sup')
  end

  def test_local_markup_with_dependency
    path = File.expand_path "../test_markup", __FILE__
    @cloud.local_markup :ex, path do |content|
      MarkupCloudTestRenderer.render(content)
    end

    assert_equal 'wat!', @cloud.render('zomg.ex', 'wat')
  end

  def thread
    @threads << Thread.new(&Proc.new)
  end
end

