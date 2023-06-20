class CreateProMatches < ActiveRecord::Migration[7.0]
  def change
    create_table :pro_matches do |t|
      t.integer :score_radiant
      t.integer :score_dire
      t.boolean :radiant_win
      t.integer :duration

      t.timestamps
    end
  end
end
