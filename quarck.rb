module DslSandbox 
  class Base
    dsl_accessor :store, :author, :collection
  end

  class Collection
    dsl_accessor :title, :identifier, :author
  end

  class Author
    dsl_accessor :name, :uri, :email
  end
end
