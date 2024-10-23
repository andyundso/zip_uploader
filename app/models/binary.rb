class Binary < ApplicationRecord
  belongs_to :parent_resource, polymorphic: true

  has_one_attached :file
end
