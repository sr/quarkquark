$: << File.dirname(__FILE__)

module AtomPub
  module Store
    class NotFound < Exception; end
    class CollectionNotFound < NotFound; end
    class EntryNotFound < NotFound; end

    def self.new(store, config={})
      store_file = "store/#{store}"
      Kernel.require(store_file)
      klass = store.to_s.capitalize.gsub(/_(.)/) { $1.upcase }
      if const_defined?(klass)
        const_get(klass).new(config)
      else
        raise "could not find `#{name}::#{klass}' in `#{store_file}'"
      end
    rescue LoadError
      raise "could not find any store named `#{store}'"
    end

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
