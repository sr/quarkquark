require 'rubygems'
require 'spec'

require File.dirname(__FILE__) + '/../quarck'

describe DslSandbox do
  before(:each) do
    @store_proxy = DslSandbox::ServerProxy.new
  end

  describe 'global author' do
    it 'appends author' do
      server { author :name => 'foo' }.should have(1).authors
    end

    it 'raise ArgumentError if no options provided' do
      lambda { server { author } }.should raise_error(ArgumentError)
    end
  end

  describe 'global contributor' do
    it 'appends contributor' do
      server { contributor :name => 'foo' }.should have(1).contributors
    end

    it 'raise ArgumentError if no options provided' do
      lambda { server { contributor } }.should raise_error(ArgumentError)
    end
  end

  describe 'collection' do
    before(:each) do
      @collection_proxy = DslSandbox::CollectionProxy.new
      DslSandbox::CollectionProxy.stub!(:new).and_return(@collection_proxy)
    end

    it 'takes an identifier and makes a title from it' do
      collection = @store_proxy.collection(:linking)
      collection.title.to_s.should == 'Linking'
      collection.identifier.should == :linking
    end

    it 'takes an identifier and a title (in that order)' do
      collection = @store_proxy.collection(:articles, 'Foo Bar Articles')
      collection.title.to_s.should == 'Foo Bar Articles'
      collection.identifier.should == :articles
    end

    it 'takes no arguments but a block yelding a title and create an identifier from it' do
      collection = @store_proxy.collection { title 'bar' }
      collection.title.to_s.should == 'bar'
      collection.identifier.should == :bar
    end

    it 'takes an identifier and a block yielding a title' do
      collection = @store_proxy.collection(:foofoo) { title 'Foo Bar' }
      collection.title.to_s.should == 'Foo Bar'
      collection.identifier.should == :foofoo
    end

    it 'takes a block yielding a subtitle' do
      collection = @store_proxy.collection { subtitle 'In Which I Foo' }
      collection.subtitle.to_s.should == 'In Which I Foo'
    end

    it 'takes a block yielding a logo' do
      collection = @store_proxy.collection { logo 'http://example.org/logo.png' }
      collection.logo.should == 'http://example.org/logo.png'
    end

    it 'takes a block yielding an icon' do
      collection = @store_proxy.collection { icon 'http://example.org/logo.png' }
      collection.icon.should == 'http://example.org/logo.png'
    end

    it 'takes a block yielding an author' do
      collection = @store_proxy.collection :articles do
        title 'Foo Articles'
        author :name => 'Simon Rozet'
      end
      collection.title.to_s.should == 'Foo Articles'
      collection.identifier.should == :articles
      collection.should have(1).authors
      collection.authors.first.name.to_s.should == 'Simon Rozet'
    end

    it 'accepts a block yielding a contributor' do
      collection = @store_proxy.collection {
        contributor :name => 'Primo', :email => 'primo@gangstarr.com'
      }
      collection.should have(1).contributors
      collection.contributors.first.name.should == 'Primo'
      collection.contributors.first.email.should == 'primo@gangstarr.com'
    end

    describe 'author' do
      it 'takes an hash of options' do
        collection = @store_proxy.collection { author :name => 'primo' }
        collection.authors.first.name.should == 'primo'
      end
    end

    describe 'contributor' do
      it 'takes an hash of options' do
        collection = @store_proxy.collection { contributor :name => 'primo' }
        collection.contributors.first.name.should == 'primo'
      end
    end
  end
end
