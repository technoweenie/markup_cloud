try:
    import locale
    locale.setlocale(locale.LC_ALL, '')
except:
    pass

import sys
import zmq
from docutils.core import publish_parts
from docutils.writers.html4css1 import Writer

SETTINGS = {
    'cloak_email_addresses': True,
    'file_insertion_enabled': False,
    'raw_enabled': False,
    'strip_comments': True,
    'doctitle_xform': False,
    'report_level': 5,
}

if len(sys.argv) > 1:
    address = sys.argv[1]
else:
    address = 'tcp://127.0.0.1:5555'

context = zmq.Context()
socket = context.socket(zmq.REP)
socket.bind(address)

writer = Writer()

while True:
  (name, text) = socket.recv_multipart()
  parts = publish_parts(text, writer=writer, settings_overrides=SETTINGS)
  if 'html_body' in parts:
      html = parts['html_body']
      rendered = html.encode('utf-8')
  else:
      rendered = ''
  socket.send_unicode(rendered)

