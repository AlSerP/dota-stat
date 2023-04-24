class AddReferencesToMatchStat < ActiveRecord::Migration[7.0]
  def change
    add_reference :heros, :match_stat, foreign_key: true
    add_reference :accounts, :match_stat, foreign_key: true
    add_reference :match_stats, :match, foreign_key: true
  end
end
