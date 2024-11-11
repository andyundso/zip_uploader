class Binary < ApplicationRecord
  belongs_to :folder

  has_one_attached :file

  scope :accessible_for, ->(user) {
    where(folder: Folder.accessible_for(user))
  }
end
