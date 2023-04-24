class AddStarttimeToMatchAndStat < ActiveRecord::Migration[7.0]
  def change
    add_column :matches, :start_time, :datetime
    add_column :matches, :duration, :integer
    add_column :match_stats, :start_time, :datetime
  end
end
