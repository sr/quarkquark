require File.dirname(__FILE__) + '/spec_helper' 
require 'dsl'
require File.dirname(__FILE__) + '/../lib/builder' # conflict with the gem builder

describe AtomPub::Builder do
  before(:each) do
    @proxy = AtomPub::DSL::ServerProxy.new
  end

  describe 'When initializing store' do
    before(:each) do
      module AtomPub::Store; class MyAtomPubStore; end; end
      @store = mock('MyAtomPubStore')
    end

    it 'initialize the store with given options' do
      @proxy.should_receive(:store).twice.and_return([:my_atom_pub_store, {:foo => 1}])
      AtomPub::Store::MyAtomPubStore.should_receive(:new).with(:foo => 1).and_return(@store)
      @server = AtomPub::Builder.new(@proxy)
    end
  end
end
