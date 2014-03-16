class Article 
  include Mongoid::Document

  embeds_many :reviews
  embeds_many :update_reviews

  field :title
  field :review_count, type: Integer, default: 0
  field :update_review_count, type: Integer, default: 0

end
