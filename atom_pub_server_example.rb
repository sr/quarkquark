require File.dirname(__FILE__) + '/lib/atom_pub/dsl'

server do
  store :memory
  author :name  => 'Simon Rozet',
         :email => 'simon@rozet.name'

  collection do
    title 'Articles'
    author :name => 'John Smith'
  end

  collection :linking
  collection :foo, 'Foo Bar Spam'

  collection :photo do
    title 'My not-so-good photography'
  end
end
