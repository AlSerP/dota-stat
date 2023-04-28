class AddRadiantWinToMatch < ActiveRecord::Migration[7.0]
  def change
    add_column :matches, :radiant_win, :boolean
    add_column :matches, :replay_url, :string
  end
end
