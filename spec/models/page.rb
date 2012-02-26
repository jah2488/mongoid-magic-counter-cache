class Page
  include Mongoid::Document
  include Mongoid::CounterCache

  embedded_in :book
  counter_cache :book, :type => Integer, :default => 0

  field :title
end
