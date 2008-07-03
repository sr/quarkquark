module AtomPub
  class Builder
    def initialize(server_proxy)
      @proxy = server_proxy
      build
    end

    def build
      @proxy.store
    end
  end
end
