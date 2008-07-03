require File.dirname(__FILE__) + '/spec_helper'
require 'atom_pub_server'

describe AtomPub::Server do
  before(:each) do
    module AtomPub::Store; class DataMapper; end; end

    @server = AtomPub::Server.new
    @store = mock('DataMapperStore', :register_collection => true)
    AtomPub::Store::DataMapper.stub!(:new).and_return(@store)
  end

  describe 'When registering a store' do
    it 'requires specified store' do
      Kernel.should_receive(:require).with('data_mapper_store').and_return(true)
      @server.store(:data_mapper)
    end

    it 'raises LoadError with an useful message if unknown store' do
      lambda {
        @server.store(:data_mapper)
      }.should raise_error(RuntimeError, "Unknown store `data_mapper'.")
    end

    it 'initializes the store with given options' do
      Kernel.stub!(:require).and_return(true)
      AtomPub::Store::DataMapper.should_receive(:new).with(:adapter => 'sqlite3')
      @server.store(:data_mapper, :adapter => 'sqlite3')
    end
  end

  %w(author contributor).each do |person_type|
    describe "global #{person_type}" do
      it "appends #{person_type}" do
        @server.send(person_type, :name => 'foo')
        @server.send("#{person_type}s").length.should == 1
      end

      it 'raises ArgumentError if no options provided' do
        lambda {
          @server.send(person_type)
        }.should raise_error(ArgumentError)
      end
    end
  end

  describe 'collection' do
    before(:each) do
      Kernel.should_receive(:require).with('data_mapper_store').and_return(true)
      @server.store :data_mapper
    end

    it 'raises RuntimeError if not store configured' do
      lambda {
        AtomPub::Server.new.collection
      }.should raise_error(RuntimeError, 'Please configure a store first.')
    end

    it 'register the collection to the store' do
      @store.should_receive(:register_collection).exactly(3).times
      3.times { |i| @server.collection "foo_#{i}".to_sym }
    end

    it 'takes an identifier and makes a title from it' do
      collection = @server.collection(:linking)
      collection.title.to_s.should == 'Linking'
      collection.identifier.should == :linking
    end

    it 'takes an identifier and a title (in that order)' do
      collection = @server.collection(:articles, 'Foo Bar Articles')
      collection.title.to_s.should == 'Foo Bar Articles'
      collection.identifier.should == :articles
    end


    it 'takes no arguments but a block yelding a title and create an identifier from it' do
      collection = @server.collection { title 'bar' }
      collection.title.to_s.should == 'bar'
      collection.identifier.should == :bar
    end

    it 'takes an identifier and a block yielding a title' do
      collection = @server.collection(:foofoo) { title 'Foo Bar' }
      collection.title.to_s.should == 'Foo Bar'
      collection.identifier.should == :foofoo
    end


    %w(title subtitle logo icon).each do |attribute|
      it "takes a block yielding a #{attribute}" do
        collection = @server.collection { eval("#{attribute} 'value'") }
        collection.send(attribute).to_s.should == 'value'
      end
    end

    # TODO: DRY the two fellowing examples
    it 'takes a block yielding an author' do
      collection = @server.collection { author :name => 'Primo' }
      collection.should have(1).authors
      collection.authors.first.name.to_s.should == 'Primo'
    end

    it 'accepts a block yielding a contributor' do
      collection = @server.collection { contributor :name => 'Primo' }
      collection.should have(1).contributors
      collection.contributors.first.name.should == 'Primo'
    end
  end
end
