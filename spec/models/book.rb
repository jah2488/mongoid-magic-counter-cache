class Book
  include Mongoid::Document
  include Mongoid::CounterCache

  belongs_to :library
  embeds_many :pages

  field :title
  field :page_count, :type => Integer, :default => 0

  counter_cache :library
end
