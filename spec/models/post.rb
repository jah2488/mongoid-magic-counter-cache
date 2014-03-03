class Post 
  include Mongoid::Document

  field :article
  field :comment_count, :type => Integer, :default => 0

  has_many :comments

end
