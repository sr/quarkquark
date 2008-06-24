require File.dirname(__FILE__) + '/quarck'

atom_pub_server = server do
  # same as for author
  store :memory,  :adapter  => 'sqlite3',
                  :database => 'entries.sqlite3'
  # register a default author for all the collections
  # if you want to assigns a different author to a collection,
  # just use `author' in the collection block
  author :name  => 'Simon Rozet',
         :email => 'simon@rozet.name'

  # it could be done by using rack's 'use' instead...
  # also, how about auth per-collection?
  authenticate :login => 'simon',
               :password => 'foobarspam'

  # which one is best? both?
  collection do
    title 'Articles'
    author :name => 'John Smith'
  end

  # will use global author and global authentication
  collection :linking
  collection :foo, 'Foo Bar Spam'
  collection 'My Collection Title'

  collection :photo do
    title 'My not-so-good photography'
  end
end

puts atom_pub_server.inspect
