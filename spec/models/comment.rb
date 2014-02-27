class Comment
  include Mongoid::Document
  include Mongoid::MagicCounterCache

  belongs_to :post

  field :remark
  field :is_published, type: Mongoid::Boolean, default: false

  counter_cache :post, :if => Proc.new { |act| (act.is_published)  }
end
