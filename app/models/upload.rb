class Upload < ApplicationRecord
  belongs_to :user

  has_one :root_folder, class_name: "Folder", dependent: :destroy

  has_one_attached :file

  before_validation -> { self.file_name = file.blob.filename if file_name.blank? }
  after_create_commit -> { ZipAnalyzerJob.perform_later(self.id) }

  scope :analysis_pending, -> { where(analyzed_at: nil) }

  validates :file_name, presence: true
end
