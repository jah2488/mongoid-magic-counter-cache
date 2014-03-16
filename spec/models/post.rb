class Post 
  include Mongoid::Document

  field :article
  field :comment_count, :type => Integer, :default => 0

  has_many :comments

  field :update_comment_count, :type => Integer, :default => 0
  has_many :update_comments
end
