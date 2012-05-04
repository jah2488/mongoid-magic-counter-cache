class Book
  include Mongoid::Document
  include Mongoid::MagicCounterCache

  belongs_to :library
  embeds_many :foreign_publications, :class_name => "Book::ForeignPublication"
  embeds_many :pages

  field :title
  field :foreign_publication_count, :type => Integer, :default => 0
  field :page_count, :type => Integer, :default => 0

  counter_cache :library
end
