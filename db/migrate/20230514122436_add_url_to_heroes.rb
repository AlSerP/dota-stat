class AddUrlToHeroes < ActiveRecord::Migration[7.0]
  def change
    add_column :heros, :avatar_url, :string
  end
end
