Mongoid Counter Cache
=======

## DESCRIPTION

Mongoid Counter Cache is a simple mongoid extension to add basic counter cache functionality to Embedded and Referenced Mongoid Documents.


## INSTALLATION

### RubyGems

    $ [sudo] gem install mongoid_counter_cache

### GemFile

    gem 'mongoid_counter_cache'

## USAGE

First add a field to the document where you will be accessing the counter cache from.

    class Library
      include Mongoid::Document

      field :name
      field :city
      field :book_count
      has_many :books

    end

Then in the referrenced/Embedded document. Include `Mongoid::CounterCache`

    class Book
      include Mongoid::Document
      include Mongoid::CounterCache

      field :first
      field :last

      belongs_to    :library
      counter_cache :library
    end


    => @library.book_count
    => 990

### Alternative Syntax

If you do not wish to use the `model_count` naming convention, you can override the defaults by specifying the `:field` parameter.

    counter_cache :library, :field => "total_amount_of_books"

## TODO

  1. Thoroughly Test embedded associations
  2. Add additional options parameters
  3. Simplify syntax (I.E. including CounterCache will add counts for all `belongs_to` associations on a document 
## CONTRIBUTE

If you'd like to contribute, feel free to fork and merge until your heart is content
