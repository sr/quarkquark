require 'rubygems'
require 'spec'

require File.dirname(__FILE__) + '/../quarck'

describe DslSandbox do
  before(:each) do
    @store_proxy = DslSandbox::ServerProxy.new
  end

  describe 'collection' do
    before(:each) do
      @collection_proxy = DslSandbox::CollectionProxy.new
      DslSandbox::CollectionProxy.stub!(:new).and_return(@collection_proxy)
    end

    it 'accepts to only be given an identifier and convert it to a title' do
      collection = @store_proxy.collection(:linking)
      collection.title.to_s.should == 'Linking'
      collection.identifier.should == :linking
    end

    it 'accepts to be given both an identifier and a title (in that order)' do
      collection = @store_proxy.collection(:articles, 'Foo Bar Articles')
      collection.title.to_s.should == 'Foo Bar Articles'
      collection.identifier.should == :articles
    end

    it 'accepts no arguments with a block yielding title and create an identifier from it' do
      collection = @store_proxy.collection { title 'bar' }
      collection.title.to_s.should == 'bar'
      collection.identifier.should == :bar
    end

    it 'accepts a block with the identifier as only argument' do
      collection = @store_proxy.collection(:foofoo) { title 'Foo Bar' }
      collection.title.to_s.should == 'Foo Bar'
      collection.identifier.should == :foofoo
    end

    it 'accepts a block yielding an author' do
      pending 'needs to figure out how to stub CollectionProxy properly'
    end
  end
end
