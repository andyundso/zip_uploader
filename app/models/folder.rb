class Folder < ApplicationRecord
  has_ancestry

  belongs_to :upload, inverse_of: :root_folder, optional: true
  has_many :binaries, dependent: :destroy

  validate :needs_either_ancestry_or_upload

  scope :accessible_for, ->(user) {
    where(
      root_id: Folder.roots.where(upload_id: user.uploads)
    ).or(where(upload_id: user.uploads))
  }

  private

  def needs_either_ancestry_or_upload
    if upload.blank? && ancestry.blank?
      errors.add(:base, "A folder either needs another folder as parent or the upload itself!")
    end
  end
end
