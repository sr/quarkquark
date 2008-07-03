$: << File.expand_path(File.dirname(__FILE__) + '/vendor/atom-tools/lib')
require 'atom/feed'

module AtomPub
  module DSL
    class ServerProxy
      attr_accessor :authors, :contributors, :collections

      def initialize
        @authors = []
        @contributors = []
        @collections = []
      end

      def store(name=nil, options={})
        Kernel.require "#{name}_store" # so it can be spec'ed
        @store = [name, options] if name
        @store
      rescue LoadError
        raise LoadError, "Unknown store `#{name}'."
      end
      alias_method :store=, :store

      %w(author contributor).each do |person_type|
        class_eval(<<-EOF, __FILE__, __LINE__)
          def #{person_type}(options={})
            raise ArgumentError if options.empty?
            @#{person_type}s << Atom::#{person_type.capitalize}.new(options)
          end
        EOF
      end

      def collection(*args, &block)
        collection = CollectionProxy.new
        case args.length
        when 1
          collection.identifier = args.first
        when 2
          collection.identifier = args.first
          collection.title      = args.last
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

      def identifier
        @identifier ||= title.to_s.split.first.downcase.to_sym
      end

      def title(value=nil)
        @atom_feed.title = value if value
        @atom_feed.title ||= @identifier.to_s.capitalize
      end

      %w(subtitle logo icon).each do |element|
        class_eval(<<-EOF, __FILE__, __LINE__)
          def #{element}(value=nil)
            @atom_feed.send(:#{element}=, value) if value
            @atom_feed.#{element}
          end
        EOF
      end

      alias :title= :title

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
end

def server(&block)
  server = AtomPub::DSL::ServerProxy.new
  server.instance_eval(&block)
  server
end
