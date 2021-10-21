class MetaContent < ApplicationRecord
  belongs_to :meta_able, polymorphic: true
end
