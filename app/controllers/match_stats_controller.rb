class MatchStatsController < ApplicationController
    def new
        heroes = DotaApi::API.get_heroes
        heroes.keys.each do |hero_id|
        unless Hero.exists?(hero_id:)
            hero = Hero.new(hero_id:, name_en: heroes[hero_id])
            hero.save
        end
        # match_stat = DotaApi::API.get_match
        match_stat = MatchStat.new(kills: 0, deaths: 0, assists: 0, last_hits: 0, denies: 0, networce: 0)
    end
end
