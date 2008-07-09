QuarckQuarck
============

Easily creates an [AtomPub][] server through a DSL.

Usage
-----

### Using AtomPub::DSL

The main goal is to be as simple as possible. Thus,
running the fellowing code will start the server
at <http://0.0.0.0:5023/service>, served by Mongrel.

    require 'atomp_pub/dsl'

    server do
      store :memory

      author :name  => 'Simon Rozet',
             :email => 'simon@rozet.name'

      collection do
        title 'Articles'
        author :name => 'John Smith'
      end

      # The global author defined at the top will be used
      # for the fellowing collections.
      collection :linking
      collection :photo, 'Photography'
    end

*NOTE*: `collection` yields an `Atom::Feed` so the you can use the fellowing
properties as well :

- subtitle
- logo
- icon
- contributor

### Using AtomPub::Server

`AtomPub::DSL` is only an interface to `AtomPub::Server`.
You can skip the DSL completely and create a server using `AtomPub::Server` directly.
As an example, here is a rackup file that can be used to start an AtomPub server
served by Mongrel available at <http://0.0.0.0:5023/service> using
`rackup my_atom_pub_server.ru -smongrel -p5023` :

    require 'atom_pub/server'
    require 'atom_pub/store/memory'

    store = AtomPub::Store::Memory.new

    use Rack::CommonLogger
    use Rack::Lint
    run AtomPub::Server.new(store)


`AtomPub::Store::Base`
---------------------

@@ TODO


Requirement
-----------

- atom-tools

License
-------

(The MIT License)
 
Copyright (c) 2008 Simon Rozet
 
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
 
The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  [AtomPub]: http://tools.ietf.org/html/rfc5023
