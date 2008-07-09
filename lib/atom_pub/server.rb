$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../../vendor/coset/lib')

require 'rubygems'
require 'atom/service'
require 'atom/collection'
require 'coset'

require File.dirname(__FILE__) + '/store'

module AtomPub
  class Server < Coset
    def initialize(store)
      @store = store
    end

    class NotFound < IndexError; end

    map_exception Store::CollectionNotFound,  404, 'Missing collection.'
    map_exception Store::EntryNotFound,       404, 'Missing entry.'
    map_exception Atom::ParseError,           400, 'Malformed entry.'
  
    GET '/service' do
      response['Content-Type'] = 'application/atomsvc+xml'
      response << @store.service_document
    end

    GET '/collections/{collection}' do
      feed = @store.feed_for(@collection)
      feed.entries.each { |e| e.edit_url = "#{request.url}/#{e.id}" }
      response['Content-Type'] = 'application/atom+xml'
      response << feed.to_s
    end

    POST '/collections/{collection}' do
      entry = @store.create(@collection, Atom::Entry.parse(request.body))
      entry.edit_url = "#{request.url}/#{entry.id}"
      response['Content-Type'] = 'application/atom+xml'
      response['Location'] = entry.edit_url
      response.status = 201
      response << entry.to_s
    end

    GET '/collections/{collection}/{entry_id}' do
      response['Content-Type'] = 'application/atom+xml'
      response << @store.retrieve(@collection, @entry_id)
    end

    PUT '/collections/{collection}/{entry_id}' do
      updated_entry = @store.update(@collection, @entry_id, Atom::Entry.parse(request.body))
      response['Content-Type'] = 'application/atom+xml'
      response << updated_entry.to_s
    end

    DELETE '/collections/{collection}/{entry_id}' do
      @store.destroy(@collection, @entry_id)
      response.status = 200
    end
  end
end
