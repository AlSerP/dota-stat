class MatchStat < ApplicationRecord
    belongs_to :match
    belongs_to :hero
    belongs_to :account
end
