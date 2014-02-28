class Article 
  include Mongoid::Document

  embeds_many :reviews

  field :title
  field :review_count, type: Integer, default: 0

end
