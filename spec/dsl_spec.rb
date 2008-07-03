require File.dirname(__FILE__) + '/spec_helper'
require 'dsl'

describe AtomPub::Server do
  before(:each) do
    @server = AtomPub::Server.new
  end

  describe 'When registering a store' do
    before(:each) do
      module AtomPub::Store; class DataMapper; end; end
      AtomPub::Store::DataMapper.stub!(:new).and_return(true)
    end

    it 'requires specified store' do
      Kernel.should_receive(:require).with('data_mapper_store').and_return(true)
      @server.store(:data_mapper)
    end

    it 'raises LoadError with an useful message if unknown store' do
      lambda {
        @server.store(:memory)
      }.should raise_error(RuntimeError, "Unknown store `memory'.")
    end

    it 'initializes the store with given options' do
      Kernel.stub!(:require).and_return(true)
      AtomPub::Store::DataMapper.should_receive(:new).with(:adapter => 'sqlite3').and_return(@store)
      @server.store(:data_mapper, :adapter => 'sqlite3')
    end
  end

  describe 'global author' do
    it 'appends author' do
      @server.author(:name => 'foo').should have(1).authors
    end

    it 'raise ArgumentError if no options provided' do
      lambda {
        @server.author
      }.should raise_error(ArgumentError)
    end
  end

  describe 'global contributor' do
    it 'appends contributor' do
      @server.contributor(:name => 'foo').should have(1).contributors
    end

    it 'raise ArgumentError if no options provided' do
      lambda {
        @server.contributor
      }.should raise_error(ArgumentError)
    end
  end

  describe 'collection' do
    before(:each) do
      @server.instance_variable_set(:@store, true)
    end

    it 'raises RuntimeError if not store configured' do
      lambda {
        AtomPub::Server.new.collection
      }.should raise_error(RuntimeError, 'Please configure a store first.')
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
