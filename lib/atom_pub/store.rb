module AtomPub
  module Store
    class NotFound < Exception; end
    class CollectionNotFound < NotFound; end
    class EntryNotFound < NotFound; end

    class Base
      def feed_for(collection)
        raise CollectionNotFound unless has_collection?(collection)
      end

      def retrieve(collection, entry_id)
        raise CollectionNotFound unless has_collection?(collection)
        raise EntryNotFound unless has_entry?(collection, entry_id)
      end

      def create(collection, entry)
        raise CollectionNotFound unless has_collection?(collection)
      end

      def update(collection, entry_id, entry)
        raise CollectionNotFound unless has_collection?(collection)
        raise EntryNotFound unless has_entry?(collection, entry_id)
      end

      def destroy(collection, entry_id)
        raise CollectionNotFound unless has_collection?(collection)
        raise EntryNotFound unless has_entry?(collection, entry_id)
      end
    end
  end
end
