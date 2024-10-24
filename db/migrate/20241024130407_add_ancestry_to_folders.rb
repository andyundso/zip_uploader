class AddAncestryToFolders < ActiveRecord::Migration[8.0]
  def change
    change_table :folders, bulk: true do |t|
      t.column :ancestry, :string
      t.index :ancestry
    end

    add_column :folders, :root_id, :virtual, type: :integer, as: "CASE WHEN ancestry = '/' THEN NULL ELSE CAST(SUBSTR(ancestry, 2, INSTR(SUBSTR(ancestry, 2), '/') - 1) AS INTEGER) END", stored: false

    remove_reference :binaries, :user, foreign_key: true, index: true, null: false
    remove_reference :folders, :user, foreign_key: true, index: true, null: false

    remove_reference :folders, :parent_resource, polymorphic: true, null: false
    remove_reference :binaries, :parent_resource, polymorphic: true, null: false

    add_reference :binaries, :folder, foreign_key: true, index: true, null: false
    add_reference :folders, :upload, foreign_key: true, index: true, null: true
  end
end
