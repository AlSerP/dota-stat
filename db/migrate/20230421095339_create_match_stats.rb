class CreateMatchStats < ActiveRecord::Migration[7.0]
  def change
    create_table :match_stats do |t|
      t.integer :kills
      t.integer :deaths
      t.integer :assists
      t.integer :last_hits
      t.integer :denies
      t.integer :networce

      t.timestamps
    end
  end
end
