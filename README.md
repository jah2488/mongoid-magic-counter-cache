Mongoid Magic Counter Cache [![Build Status](https://secure.travis-ci.org/jah2488/mongoid-magic-counter-cache.png?branch=master)](http://travis-ci.org/jah2488/mongoid-magic-counter-cache) [![Code Climate](https://codeclimate.com/github/jah2488/mongoid-magic-counter-cache.png)](https://codeclimate.com/github/jah2488/mongoid-magic-counter-cache)
=======

## DESCRIPTION

Mongoid Counter Cache is a simple mongoid extension to add basic counter cache functionality to Embedded and Referenced Mongoid Documents.
### RDOC
[http://rdoc.info/github/jah2488/mongoid-magic-counter-cache/master/frames](http://rdoc.info/github/jah2488/mongoid-magic-counter-cache/master/frames)

## INSTALLATION

#### Mongoid Magic Counter Cache requires ruby `1.9.3` at a minimum

### RubyGems
````sh
$ [sudo] gem install mongoid_magic_counter_cache
````
### GemFile
````rb
gem 'mongoid_magic_counter_cache'
````
## USAGE

First add a field to the document where you will be accessing the counter cache from.

````rb
class Library
  include Mongoid::Document

  field :name
  field :city
  field :book_count
  has_many :books

end
````
Then in the referrenced/Embedded document. Include `Mongoid::MagicCounterCache`

````rb
class Book
  include Mongoid::Document
  include Mongoid::MagicCounterCache

  field :first
  field :last

  belongs_to    :library
  counter_cache :library
end
````

````rb
$ @library.book_count
#=> 990
````
### Alternative Syntax

If you do not wish to use the `model_count` naming convention, you can override the defaults by specifying the `:field` parameter.

````rb
counter_cache :library, :field => "total_amount_of_books"
````


### Conditional Counter

If you want to maintain counter based on certain condition, then you can specify it using `:if`

````rb
class Post 
  include Mongoid::Document

  field :article
  field :comment_count

  has_many :comments

end
````
Then in the referrenced/Embedded document, add condition for counter using `:if`

````rb
class Comment
  include Mongoid::Document
  include Mongoid::MagicCounterCache

  belongs_to :post

  field :remark
  field :is_published, type: Boolean, default: false

  counter_cache :post, :if => Proc.new { |act| (act.is_published)  }
end
````

comment_count will get incremented / decremented only when `:if` condition returns `true`

### Conditional Counter After Update

In conjunction with the conditional counter, if you want to maintain counter after an update to an object, then you can specify it using `:if_update`

Using same example as above, in the referrenced/Embedded document, add an additional condition for counter using `:if_update`

````rb
class Comment
  include Mongoid::Document
  include Mongoid::MagicCounterCache

  belongs_to :post

  field :remark
  field :is_published, type: Boolean, default: false

  counter_cache :post, :if => Proc.new { |act| (act.is_published)  }, :if_update => Proc.new { |act| act.changes['is_published'] }
end
````

When a comment is saved, comment_count will get incremented / decremented if the is_published field is dirty.



## CONTRIBUTE

    If you'd like to contribute, feel free to fork and merge until your heart is content
