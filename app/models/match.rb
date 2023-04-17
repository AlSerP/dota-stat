class Match < ApplicationRecord
    validates :serial, presence: true
    validates :score_radiant, presence: true
    validates :score_dire, presence: true
end
