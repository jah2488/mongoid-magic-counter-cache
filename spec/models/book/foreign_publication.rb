class Book
  class ForeignPublication
    include Mongoid::Document
    include Mongoid::MagicCounterCache

    belongs_to :book, :inverse_of => :foreign_publications
    counter_cache :book
  end
end