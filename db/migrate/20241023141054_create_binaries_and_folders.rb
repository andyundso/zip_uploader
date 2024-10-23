class CreateBinariesAndFolders < ActiveRecord::Migration[8.0]
  def change
    create_table :binaries do |t|
      t.string :name, null: false
      t.references :parent_resource, polymorphic: true, null: false

      t.timestamps
    end

    create_table :folders do |t|
      t.string :name, null: false
      t.references :parent_resource, polymorphic: true, null: false

      t.timestamps
    end
  end
end
