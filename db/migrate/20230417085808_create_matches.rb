class CreateMatches < ActiveRecord::Migration[7.0]
  def change
    create_table :matches do |t|
      t.integer :serial
      t.integer :score_radiant
      t.integer :score_dire

      t.timestamps
    end
  end
end
