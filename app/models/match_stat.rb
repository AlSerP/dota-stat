class MatchStat < ApplicationRecord
    belongs_to :match
    belongs_to :hero
    belongs_to :account
    default_scope { order(start_time: :desc) }

    def to_s
        return "#{self.match.serial} - #{self.hero.name_en}"
    end

    class << self
        def delete_duplicates
            self.where.not(id: self.group(["match_id", "hero_id"]).select("min(id)")).delete_all
        end
    end
end
