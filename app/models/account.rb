class Account < ApplicationRecord
    has_many :match_stats
    validates :steamID32, uniqueness: true
end
