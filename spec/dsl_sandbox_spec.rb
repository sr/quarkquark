require 'rubygems'
require 'spec'

require File.dirname(__FILE__) + '/../quarck'

describe DslSandbox do
  before(:each) do
    @store_proxy = DslSandbox::ServerProxy.new
  end

  describe 'collection' do
    before(:each) do
      @collection_proxy = mock(DslSandbox::CollectionProxy)
      DslSandbox::CollectionProxy.should_receive(:new).and_return(@collection_proxy)
    end

    it 'accepts to only be given an identifier and convert it to a title' do
      @collection_proxy.should_receive(:title=).with('Linking')
      @collection_proxy.should_receive(:identifier=).with(:linking)
      @store_proxy.collection(:linking)
    end

    it 'accepts to be given both an identifier and a title (in that order)' do
      @collection_proxy.should_receive(:title=).with('Foo Bar Articles')
      @collection_proxy.should_receive(:identifier=).with(:articles)
      @store_proxy.collection(:articles, 'Foo Bar Articles')
    end

    it 'accepts a block with no arguments' do
      pending 'needs to figure out how to stub CollectionProxy properly'
      @collection_proxy.should_receive(:title=).with('foo bar')
      @collection_proxy.should_receive(:identifier=).with(:foo)
      @store_proxy.collection { title 'foo bar' }
    end

    it 'accepts a block with the identifier as only argument' do
      pending 'needs to figure out how to stub CollectionProxy properly'
      @collection_proxy.should_receive(:identifier=).with(:foofoo)
      @store_proxy.collection(:foofoo) { title 'Foo Bar' }
    end

    it 'accepts a block an author' do
      pending 'needs to figure out how to stub CollectionProxy properly'
    end
  end
end
