# Markup Cloud

Spin up a markup rendering cluster, in the cloud!

This is simply an experiment in breaking the [github/markup][] up into smaller
pieces.  Formats without a good Ruby library are now accessed through remote
ZeroMQ sockets instead of shelling out with new processes.

This is considered alpha code until it's been pushed to a gem.  Anything can
change!

[github/markup]: https://github.com/github/markup

## USAGE

It's very similar to github/markup.  First. setup a MarkupCloud and add some
renderers:

```ruby
require 'markup_cloud'
cloud = MarkupCloud.new
cloud.local_markup :md, :redcarpet do |content|
  RedcarpetCompat.new(content).to_html
end
```

You can get going with a standard set of local Ruby libraries (provided you
have the necessary gems installed).

```ruby
require 'markup_cloud/clients'
cloud = MarkupCloud.new
cloud.setup_local_clients!

cloud.render 'README.md', IO.read('README.md')
```

You can setup remote renderers that access a ZeroMQ REP server.

```ruby
require 'markup_cloud'
cloud = MarkupCloud.new
cloud.remote_markup :rst, 'tcp://127.0.0.1:5555'

cloud.render "README.rst", IO.read("README.rst")
```

Responding to these ZeroMQ messages is simple:

```ruby
require 'ffi-rzmq'
context = ZMQ::Context.new
rep = context.socket ZMQ::REP
rep.bind 'tcp://127.0.0.1:5555'

while rep.recv_strings(list = [])
  name, content = list
  rep.send_string Something.render(content)
```

```python
import zmq
context = zmq.Context()
rep = context.socket(zmq.REP)
rep.bind('tcp://127.0.0.1:5555')

while True:
  (name, content) = rep.recv_multipart()
  rep.send_unicode(Something.render(content))
```

## TODO

* Write solid ZeroMQ Python/Perl servers for ReST, POD, etc.
* Figure out if any of this is worth the hassle.

