class Album
  include Mongoid::Document

  embeds_many :songs

  field :title
  field :genre
  field :song_count, type: Integer, default: 0

end
