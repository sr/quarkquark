require File.dirname(__FILE__) + '/spec_helper' 
require 'dsl'
require File.dirname(__FILE__) + '/../lib/builder' # conflict with the gem builder

describe AtomPub::Builder do
  before(:each) do
    @proxy = AtomPub::DSL::ServerProxy.new
  end

  describe 'When initializing store' do
    before(:each) do
      @store = mock('store')
    end

    it 'initialize the store with given options' do
      @proxy.should_receive(:store).and_return(@store)
      @server = AtomPub::Builder.new(@proxy)
    end
  end
end
