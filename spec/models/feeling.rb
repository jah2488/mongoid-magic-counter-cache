class Feeling
  include Mongoid::Document
  include Mongoid::CounterCache

  belongs_to :person
  counter_cache :person, :field => "all_my_feels"
end
