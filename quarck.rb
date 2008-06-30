$: << File.expand_path(File.dirname(__FILE__) + '/vendor/atom-tools/lib')
require 'atom/feed'
require 'core_ext'

module DslSandbox 
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

    %w(author contributor).each do |person_type|
      self.class_eval <<-EOF
        def #{person_type}(options={}, &block)
          if block_given?
            person = PersonProxy.new
            person.instance_eval(&block)
            @atom_feed.#{person_type}s << person.to_atom_#{person_type}
          else
            @atom_feed.#{person_type}s.new(options)
          end
        end

        def #{person_type}s
          @atom_feed.#{person_type}s
        end
      EOF
    end
  end

  class PersonProxy
    def initialize(options={})
      @person = Atom::Person.new
    end

    %w(name email uri).each do |attribute|
      self.class_eval <<-EOF
        def #{attribute}(value=nil)
          @person.#{attribute} = value if value
          @person.#{attribute}
        end
      EOF
    end

    def to_atom_author
      Atom::Author.new(:name => @person.name, :uri => @person.uri, :email => @person.email)
    end

    def to_atom_contributor
      Atom::Contributor.new(:name => @person.name, :uri => @person.uri, :email => @person.email)
    end
  end
end

def server(&block)
  server = DslSandbox::ServerProxy.new
  server.instance_eval(&block)
  server
end
