require File.dirname(__FILE__) + '/server'

class String
  def camelize
    self.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  end
end

module AtomPub
  module DSL
    class Server
      attr_accessor :collections

      def initialize
        @collections = []
      end

      def run!
        app = AtomPub::Server.new(@store)
        app = Rack::CommonLogger.new(app)
        app = Rack::Lint.new(app)
        Rack::Handler::Mongrel.run(app, :Port => 3000)
      end

      def store(name, options={})
        Kernel.require(File.dirname(__FILE__) + "/store/#{name}_store")
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
        collection.authors << author if author && collection.authors.empty?
        collection.contributors << contributor if contributor && collection.contributors.empty?
        @store.register_collection(collection)
        collection
      end

      %w(author contributor).each do |person_type|
        class_eval <<-EOF
          def #{person_type}(options={})
            @#{person_type} = Atom::#{person_type.capitalize}.new(options) unless options.empty?
            @#{person_type}
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

      def method_missing(method, *args)
        @atom_feed.send(method, *args)
      end

      def is_a?(what)
        return true if what == Atom::Collection
        super(what)
      end

      def to_s
        @atom_feed.to_s
      end

      %w(subtitle logo icon).each do |element|
        class_eval <<-EOF
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
end

def server(&block)
  server = AtomPub::DSL::Server.new
  server.instance_eval(&block)
  server.run!
end
