class Account < ApplicationRecord
    has_many :match_stats
    validates :steamID32, uniqueness: true

    def get_last_match
        return self.match_stats ? self.match_stats.first.match : nil  
    end
end
