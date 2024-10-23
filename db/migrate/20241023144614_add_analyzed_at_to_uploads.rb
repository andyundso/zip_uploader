class AddAnalyzedAtToUploads < ActiveRecord::Migration[8.0]
  def change
    add_column :uploads, :analyzed_at, :datetime, null: true
    add_column :uploads, :file_name, :string, null: false
  end
end
