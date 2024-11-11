class AddApiTokenToUser < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :api_token, :string, null: true

    User.find_each do |user|
      user.api_token = User.generate_unique_secure_token
      user.save
    end

    change_column_null :users, :api_token, false
  end
end
