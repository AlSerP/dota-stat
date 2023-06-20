class CreateProPlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :pro_players do |t|
      t.string :name
      t.string :username
      t.integer :elo
      t.integer :position

      t.timestamps
    end
  end
end
