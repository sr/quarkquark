require 'rubygems'
require 'spec'
require File.dirname(__FILE__) + '/../lib/atom_pub/dsl'

describe AtomPub::DSL do
  before(:each) do
    module AtomPub::Store; class DataMapper; end; end
    @server = AtomPub::DSL::Server.new
    @store = mock('DataMapper', :register_collection => true)
    AtomPub::Store::DataMapper.stub!(:new).and_return(@store)
  end

  describe 'When registering a store' do
    it 'loads and instantiate it with given options using AtomPub::Store.new' do
      AtomPub::Store.should_receive(:new).with(:data_mapper, :adapter => 'sqlite3')
      @server.store(:data_mapper, :adapter => 'sqlite3')
    end
  end

  %w(author contributor).each do |person_type|
    it "registers global #{person_type}" do
      @server.send(person_type, {:name => 'foo'})
      @server.send(person_type).name.to_s.should == 'foo'
    end
  end

  describe 'collection' do
    before(:each) do
      Kernel.stub!(:require).and_return(true)
      @server.store :data_mapper
    end

    it 'raises RuntimeError if not store configured' do
      lambda {
        AtomPub::DSL::Server.new.collection
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

    # TODO: DRY the fellowing examples
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

    %w(author contributor).each do |person_type|
      it "uses the global #{person_type} if no author provided" do
        @server.send(person_type, :name => 'Big-L')
        collection = @server.collection { title 'Street Struck' }
        collection.send("#{person_type}s").length.should == 1
        collection.send("#{person_type}s").first.name.to_s.should == 'Big-L'
      end

      it "doesn't erase the collection-specific #{person_type}" do
        @server.send(person_type, :name => 'Common')
        collection = @server.collection { title 'foo'; send(person_type, :name => 'blargh') }
        collection.send("#{person_type}s").length.should == 1
        collection.send("#{person_type}s").first.name.to_s.should == 'blargh'
      end
    end
  end
end
