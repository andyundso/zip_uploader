class CreateUploads < ActiveRecord::Migration[8.0]
  def change
    create_table :uploads do |t|
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps
    end
  end
end
