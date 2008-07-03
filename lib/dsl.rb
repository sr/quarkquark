$: << File.expand_path(File.dirname(__FILE__) + '/vendor/atom-tools/lib')
require 'atom/feed'
require 'core_ext'

module AtomPub
  class Server
    attr_accessor :authors, :contributors, :collections

    def initialize
      @authors = []
      @contributors = []
      @collections = []
    end

    def store(name, options={})
      Kernel.require "#{name}_store"
      klass = name.to_s.camelize
      @store = AtomPub::Store.const_get(klass).new(options)
    rescue LoadError
      raise "Unknown store `#{name}'."
    end

    def collection(*args, &block)
      raise 'Please configure a store first.' unless @store

      collection = Collection.new
      case args.length
      when 1
        collection.identifier = args.first
      when 2
        collection.identifier = args.first
        collection.title      = args.last
      end

      collection.instance_eval(&block) if block_given?
      atom_store.register_collection(collection)
      collection
    end

    %w(author contributor).each do |person_type|
      class_eval(<<-EOF, __FILE__, __LINE__)
        def #{person_type}(options={})
          raise ArgumentError if options.empty?
          @#{person_type}s << Atom::#{person_type.capitalize}.new(options)
        end
      EOF
    end
  end

  class Collection
    attr_accessor :identifier

    def initialize
      @atom_feed = Atom::Feed.new
    end

    def identifier
      @identifier ||= title.to_s.split.first.downcase.to_sym
    end

    def title(value=nil)
      @atom_feed.title = value if value
      @atom_feed.title ||= @identifier.to_s.capitalize
    end

    alias :title= :title

    %w(subtitle logo icon).each do |element|
      class_eval(<<-EOF, __FILE__, __LINE__)
        def #{element}(value=nil)
          @atom_feed.send(:#{element}=, value) if value
          @atom_feed.#{element}
        end
      EOF
    end

    %w(author contributor).each do |person_type|
      class_eval <<-EOF
        def #{person_type}(options={})
          person = Atom::#{person_type.capitalize}.new(options)
          @atom_feed.#{person_type}s << person
        end

        def #{person_type}s; @atom_feed.#{person_type}s; end
      EOF
    end
  end
end

def server(&block)
  server = AtomPub::DSL::ServerProxy.new
  server.instance_eval(&block)
  server
end
