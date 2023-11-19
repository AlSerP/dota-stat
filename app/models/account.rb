class Account < ApplicationRecord
    has_many :match_stats
    validates :steamID32, uniqueness: true

    PRIME_STEAMID32 = [91737704, 85134343, 237330027, 259411999, 196215124]

    def get_last_match
        return matches? ? self.match_stats.first.match : nil  
    end

    def get_matches_per_week
        return nil unless matches?
        
        week_ago = DateTime.now.to_date - 7

        return match_stats.where('start_time >= ?', week_ago)
    end

    def get_popular_hero
        return nil unless matches?

        hero_hash = get_heroes_popularity(self.match_stats)
        return Hero.find(hero_hash.keys[0])
    end

    def get_popular_hero_for_week
        return nil unless matches?

        hero_hash = get_heroes_popularity(self.get_matches_per_week)
        puts self.get_matches_per_week
        puts hero_hash
        return Hero.find(hero_hash.keys[0])
    end

    def get_heroes_popularity(stats)
        asc_heroes = stats.group(:hero_id).count.sort_by {|_key, value| value}
        return asc_heroes.reverse.to_h
    end

    def matches?
        return self.match_stats ? true : false 
    end
end
