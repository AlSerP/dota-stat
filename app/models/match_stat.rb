class MatchStat < ApplicationRecord
    belongs_to :matches
    has_one :hero
    has_one :account
end
