require File.dirname(__FILE__) + '/spec_helper' 
require 'dsl'
require File.dirname(__FILE__) + '/../lib/builder' # conflicts with the gem builder

describe AtomPub::Builder do
  before(:each) do
    @proxy = AtomPub::DSL::ServerProxy.new
  end

  describe 'When initializing store' do
    before(:each) do
      module AtomPub::Store; class MyAtomPubStore; end; end
      @store = mock('MyAtomPubStore', :register_collection => true)
      AtomPub::Store::MyAtomPubStore.stub!(:new).and_return(@store)
      @proxy.collection { title 'foo' }
      @proxy.collection(:blah) { title 'blah blah' }
      @proxy.stub!(:store).and_return([:my_atom_pub_store, {:foo => 1}])
    end

    it 'initializes the store with given options' do
      @proxy.should_receive(:store).twice.and_return([:my_atom_pub_store, {:foo => 1}])
      AtomPub::Store::MyAtomPubStore.should_receive(:new).with(:foo => 1).and_return(@store)
      @server = AtomPub::Builder.new(@proxy)
    end

    it 'registers collections' do
      @store.should_receive(:register_collection).with(@proxy.collections.first)
      @store.should_receive(:register_collection).with(@proxy.collections.last)
      AtomPub::Builder.new(@proxy)
    end
  end
end
