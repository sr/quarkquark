$: << File.expand_path(File.dirname(__FILE__) + '/vendor/atom-tools/lib')
require 'atom/feed'

module DslSandbox 
  class Class
    def self.dsl_accessor
    end
  end

  class ServerProxy
    def initialize
      @authors = []
      @collections = []
    end

    def store(name, options={})
      @store = [name, options={}] if name
      @store || name
    end
    alias_method :store=, :store

    def author(options={}, &block)
      raise ArgumentError if options.empty? && !block_given?
      author = AuthorProxy.new(options)
      author.instance_eval(&block) if block_given?
      @authors << author
    end

    def collection(*args, &block)
      collection = CollectionProxy.new
      case args.length
      when 1
        case identifier_or_title = args.first
        when Symbol
          collection.title      = identifier_or_title.to_s.capitalize
          collection.identifier = identifier_or_title
        when String
          collection.title      = identifier_or_title
          collection.identifier = identifier_or_title.split.first.downcase.to_sym
        end
      when 2
        collection.title      = args.last
        collection.identifier = args.first
      end

      collection.instance_eval(&block) if block_given?
      @collections << collection
    end

    def authenticate(*args)
    end
  end

  class CollectionProxy
    attr_writer :identifier

    def initialize
      @atom_feed = Atom::Feed.new
    end

    def title(value=nil)
      @atom_feed.title = value if value
      @atom_feed.title
    end
    alias_method :title=, :title

    def author(options={})
      @atom_feed.authors.new(options)
    end
  end

  class AuthorProxy
    def initialize(options={})
      @author = Atom::Person.new
    end
  end
end

def server(&block)
  server = DslSandbox::ServerProxy.new
  server.instance_eval(&block)
  server
end
