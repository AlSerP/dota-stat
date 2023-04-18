class CreateHeros < ActiveRecord::Migration[7.0]
  def change
    create_table :heros do |t|
      t.integer :hero_id
      t.string :name_en
      t.string :name_ru

      t.timestamps
    end
  end
end
