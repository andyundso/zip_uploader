class Upload < ApplicationRecord
  belongs_to :user

  has_many :files, inverse_of: :parent_resource, dependent: :destroy
  has_many :folders, inverse_of: :parent_resource, dependent: :destroy

  has_one_attached :file
end
