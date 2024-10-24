class AddUserReferenceToFilesAndFolders < ActiveRecord::Migration[8.0]
  def change
    add_reference :binaries, :user, foreign_key: true, index: true, null: false
    add_reference :folders, :user, foreign_key: true, index: true, null: false
  end
end
