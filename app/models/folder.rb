class Folder < ApplicationRecord
  belongs_to :parent_resource, polymorphic: true

  has_many :files, inverse_of: :parent_resource, dependent: :destroy
end
