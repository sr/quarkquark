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
      collection = @store_proxy.collection :articles do
        title 'Foo Articles'
        author :name => 'Simon Rozet'
      end
      collection.title.to_s.should == 'Foo Articles'
      collection.identifier.should == :articles
      collection.should have(1).authors
      collection.authors.first.name.to_s.should == 'Simon Rozet'
    end

    it 'accepts a block yielding a subtitle' do
      collection = @store_proxy.collection { subtitle 'In Which I Foo' }
      collection.subtitle.to_s.should == 'In Which I Foo'
    end

    it 'accepts a block yielding a contributor' do
      collection = @store_proxy.collection {
        contributor :name => 'Primo', :email => 'primo@gangstarr.com'
      }
      collection.should have(1).contributors
      collection.contributors.first.name.should == 'Primo'
      collection.contributors.first.email.should == 'primo@gangstarr.com'
    end

    it 'accepts a block yielding a logo' do
      collection = @store_proxy.collection { logo 'http://example.org/logo.png' }
      collection.logo.should == 'http://example.org/logo.png'
    end

    it 'accepts a block yielding an icon' do
      collection = @store_proxy.collection { icon 'http://example.org/logo.png' }
      collection.icon.should == 'http://example.org/logo.png'
    end

    describe 'author' do
      it 'accepts an hash of options' do
        collection = @store_proxy.collection { author :name => 'primo' }
        collection.authors.first.name.should == 'primo'
      end

      it 'accepts a block' do
        collection = @store_proxy.collection do
          author do
            name 'primo'
            email 'primo@real-hip-hop.org'
            uri 'http://real-hip-hop.org/primo'
          end
        end
        collection.authors.first.name.should == 'primo'
        collection.authors.first.email.should == 'primo@real-hip-hop.org'
        collection.authors.first.uri.should == 'http://real-hip-hop.org/primo'
      end
    end
  end
end
