class MatchStat < ApplicationRecord
    belongs_to :match
    belongs_to :hero
    belongs_to :account
    default_scope { order(start_time: :desc) }
end
