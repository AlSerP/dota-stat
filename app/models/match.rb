class Match < ApplicationRecord
    has_many :match_stats, dependent: :destroy
    validates :serial, presence: true, uniqueness: true
    validates :score_radiant, presence: true
    validates :score_dire, presence: true
end
