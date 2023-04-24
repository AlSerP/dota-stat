class Match < ApplicationRecord
    has_many :match_stats
    validates :serial, presence: true
    validates :score_radiant, presence: true
    validates :score_dire, presence: true
end
