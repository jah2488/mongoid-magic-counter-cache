class Library
  include Mongoid::Document

  field :title
  field :book_count, :type => Integer, :default => 0

  has_many :books

end
