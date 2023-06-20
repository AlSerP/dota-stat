class CreateProStats < ActiveRecord::Migration[7.0]
  def change
    create_table :pro_stats do |t|
      t.integer :kills
      t.integer :deaths
      t.integer :assists
      t.integer :position
      t.float :elo_diff
      t.references :pro_player, foreign_key: true
      t.references :pro_match, foreign_key: true

      t.timestamps
    end
  end
end
