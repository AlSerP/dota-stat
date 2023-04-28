class Account < ApplicationRecord
    has_many :match_stats
    validates :steamID32, uniqueness: true

    PRIME_STEAMID32 = [91737704, 85134343, 237330027, 259411999]

    def get_last_match
        return self.match_stats ? self.match_stats.first.match : nil  
    end
end
