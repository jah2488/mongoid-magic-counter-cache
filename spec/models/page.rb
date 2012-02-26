class Page
  include Mongoid::Document
  include Mongoid::MagicCounterCache

  embedded_in :book
  counter_cache :book, :type => Integer, :default => 0

  field :title
end
