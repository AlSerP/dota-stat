class AddAvatarUrlToAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :avatar_url, :string
  end
end
