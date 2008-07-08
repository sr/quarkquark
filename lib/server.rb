$: << File.expand_path(File.dirname(__FILE__) + '/../vendor/coset/lib')
require 'atom/service'
require 'atom/collection'
require 'coset'

module AtomPub
  class Server < Coset
    def initialize(svc=Atom::Service.new)
      @svc = svc
    end

    class NotFound < IndexError; end
    map_exception NotFound, 404
  
    def feed
      @svc.workspaces.first.collections.find { |feed| feed.id == @feed } or
        raise NotFound
    end

    def entry
      feed.entries.find { |entry| entry.id == @id } or
        raise NotFound
    end


    GET '/service' do
      response['Content-Type'] = 'application/atomserv+xml'
      response << @svc.to_s
    end

    GET '/collections/{feed}' do
      feed.entries.each { |entry|
        unless entry.edit_url
          link = Atom::Link.new.update "rel" => "edit",
          "href" => "#{feed.id}/#{entry.id}"
          entry.links << link
        end
      }
    
      response['Content-Type'] = 'application/atom+xml'
      response << feed.to_s
    end

    POST '/collections/{feed}' do
      new_entry = Atom::Entry.parse(req.body)

      feed << new_entry
      response['Content-Type'] = 'application/atom+xml'
      response.status = 201
      response << new_entry.to_s
    end

    GET '/{feed}/{id}' do
      response['Content-Type'] = 'application/atom+xml'
      response << entry.to_s
    end

    PUT '/{feed}/{id}' do
      new_entry = Atom::Entry.parse(req.body)
      feed << new_entry
      new_entry.id = @id
    
      response['Content-Type'] = 'application/atom+xml'
      response << new_entry.to_s
    end

    DELETE '/{feed}/{id}' do
      feed.entries.delete_if { |e| e.id == @id }
    end
  end
end