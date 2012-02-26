class Person
  include Mongoid::Document
  has_many :feelings

  field :name
  field :all_my_feels
end
