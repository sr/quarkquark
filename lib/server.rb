$: << File.expand_path(File.dirname(__FILE__) + '/../vendor/coset/lib')
require 'atom/service'
require 'atom/collection'
require 'coset'

module AtomPub
  class Server < Coset
    def initialize(store)
      @store = store
    end

    class NotFound < IndexError; end

    map_exception NotFound, 404
    map_exception Atom::ParseError, 500
  
    GET '/service' do
      response['Content-Type'] = 'application/atomsvc+xml'
      response << @store.service_document
    end

    GET '/collections/{collection}' do
      raise NotFound unless @store.has_collection?(@collection)
      response << @store.feed_for(@collection)
      response['Content-Type'] = 'application/atom+xml'
    end

    POST '/collections/{collection}' do
      raise NotFound unless @store.has_collection?(@collection)
      entry = @store.create(@collection, Atom::Entry.parse(request.body))
      response['Content-Type'] = 'application/atom+xml'
      response['Location'] = "#{request.url}/#{entry.id}"
      response.status = 201
      response << entry.to_s
    end

    GET '/collections/{collection}/{entry_id}' do
      raise NotFound unless @store.has_collection?(@collection)
      response['Content-Type'] = 'application/atom+xml'
      response << @store.retrieve(@collection, @entry_id)
    end

    PUT '/collections/{collection}/{entry_id}' do
      raise NotFound unless @store.has_collection?(@collection)
      updated_entry = @store.update(@collection, @entry_id, Atom::Entry.parse(request.body))
      response['Content-Type'] = 'application/atom+xml'
      response << updated_entry.to_s
    end

    DELETE '/{feed}/{id}' do
      feed.entries.delete_if { |e| e.id == @id }
    end
  end
end
