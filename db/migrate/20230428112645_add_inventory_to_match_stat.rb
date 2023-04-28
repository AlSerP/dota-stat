class AddInventoryToMatchStat < ActiveRecord::Migration[7.0]
  def change
    add_column :match_stats, :item_0, :integer
    add_column :match_stats, :item_1, :integer
    add_column :match_stats, :item_2, :integer
    add_column :match_stats, :item_3, :integer
    add_column :match_stats, :item_4, :integer
    add_column :match_stats, :item_5, :integer
    add_column :match_stats, :backpack_0, :integer
    add_column :match_stats, :backpack_1, :integer
    add_column :match_stats, :backpack_2, :integer
    add_column :match_stats, :item_neutral, :integer
    add_column :match_stats, :hero_damage, :integer
    add_column :match_stats, :hero_healing, :integer
    add_column :match_stats, :tower_damage, :integer
    add_column :match_stats, :level, :integer
  end
end
