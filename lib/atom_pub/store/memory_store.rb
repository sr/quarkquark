module AtomPub
  module Store
    class Memory
      def initialize(options={})
        @service = Atom::Service.new
        @workspace = @service.workspaces.new
        @feeds = {}
      end

      def register_collection(feed)
        @feeds[feed.identifier] = feed
        collection = Atom::Collection.new("/collections/#{feed.identifier}")
        collection.title = feed.title
        collection.accepts = 'application/atom+xml;type=entry'
        @workspace.collections << collection
      end

      def has_collection?(identifier)
        @feeds.has_key?(identifier.to_sym)
      end

      def service_document
        @service.to_s
      end

      def feed_for(collection)
        super(collection)
        feed = find_feed(collection).dup
        feed.entries.sort_by { |e| e.edited }
        feed
      end

      def create(collection, entry)
        new_entry = entry.dup
        new_entry.id = find_feed(collection).entries.length + 1
        new_entry.edited = Time.now
        @feeds[collection.to_sym].entries << new_entry
        new_entry
      end

      def retrieve(collection, entry_id)
        find_feed(collection).entries.find { |e| e.id.to_s == entry_id.to_s }
      end

      def update(collection, entry_id, updated_entry)
        find_feed(collection).entries.delete_if { |e| e.id.to_s == entry_id.to_s }
        updated_entry.id == entry_id
        find_feed(collection).entries << updated_entry
        updated_entry
      end

      def destroy(collection, entry_id)
        find_feed(collection).entries.delete_if { |e| e.id.to_s == entry_id.to_s }
      end

      private
        def find_collection(identifier)
          @workspace.collections.detect { |c| c.href == "/collections/#{identifier}" }
        end

        def find_feed(identifier)
          @feeds[identifier.to_sym]
        end
    end
  end
end
