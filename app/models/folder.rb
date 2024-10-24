class Folder < ApplicationRecord
  belongs_to :parent_resource, polymorphic: true
  belongs_to :user

  has_many :folders, as: :parent_resource, dependent: :destroy
  has_many :binaries, as: :parent_resource, dependent: :destroy
end
