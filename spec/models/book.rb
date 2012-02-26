class Book
  include Mongoid::Document
  include Mongoid::MagicCounterCache

  belongs_to :library
  embeds_many :pages

  field :title
  field :page_count, :type => Integer, :default => 0

  counter_cache :library
end
