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
      collection
    end

    def authenticate(*args)
    end
  end

  class CollectionProxy
    attr_accessor :identifier

    def initialize
      @atom_feed = Atom::Feed.new
    end

    %w(subtitle logo icon).each do |element|
      self.class_eval %Q{
        def #{element}(value=nil)
          @atom_feed.send("#{element}=", value) if value
          @atom_feed.send("#{element}")
        end
      }
    end

    def title(value=nil)
      if value
        @atom_feed.title = value
        @identifier = value.split.first.downcase.to_sym unless @identifier
      end
      @atom_feed.title
    end
    alias_method :title=, :title

    def author(options={}, &block)
      if block_given?
        author = AuthorProxy.new
        author.instance_eval(&block)
        @atom_feed.authors << author.to_atom_author
      else
        @atom_feed.authors.new(options)
      end
    end

    def contributor(options={})
      @atom_feed.contributors.new(options)
    end

    def authors
      @atom_feed.authors
    end

    def contributors
      @atom_feed.contributors
    end
  end

  class AuthorProxy
    def initialize(options={})
      @author = Atom::Author.new
    end

    def name(value=nil)
      @author.name = value if value
      @author.name
    end

    def email(value=nil)
      @author.email = value if value
      @author.email
    end

    def uri(value=nil)
      @author.uri = value if value
      @author.uri
    end

    def to_atom_author
      @author
    end
  end
end

def server(&block)
  server = DslSandbox::ServerProxy.new
  server.instance_eval(&block)
  server
end
