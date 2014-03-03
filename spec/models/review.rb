class Review
  include Mongoid::Document
  include Mongoid::MagicCounterCache

  embedded_in   :article
  counter_cache :article, :if => Proc.new { |act| (act.is_published)  }

  field :comment
  field :is_published, type: Boolean, default: false
end
