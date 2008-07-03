module AtomPub
  class Builder
    def initialize(server_proxy)
      @proxy = server_proxy
      build
    end

    def build
      @store = instantiate_store
      @proxy.collections.each { |collection|
        @store.register_collection(collection)
      }
    end

    def instantiate_store
      klass = @proxy.store.first.to_s.
        gsub(/\/(.?)/) { "::" + $1.upcase }.
        gsub(/(^|_)(.)/) { $2.upcase }
      AtomPub::Store.const_get(klass).new(@proxy.store.last)
    end
  end
end
