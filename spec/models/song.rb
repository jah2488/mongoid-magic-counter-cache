class Song
  include Mongoid::Document
  include Mongoid::MagicCounterCache
  embedded_in   :album
  counter_cache :album
  field :title
  field :track_length
end
