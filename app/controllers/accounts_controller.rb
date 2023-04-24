require "#{Rails.root}/lib/tasks/dota_api.rb"

class AccountsController < ApplicationController
    include DotaApi
    # DEFAULT_STEAMID32 = [91737704, 85134343]
    DEFAULT_STEAMID32 = [91737704, 85134343]

    def show
        @account = Account.find(params[:id])
    end

    def update_matches
        @account = Account.find(params[:id])

        matches_id = DotaApi::API.parce_matches_id(@account.steamID32, start_from=@account.get_last_match.serial)
        # puts "Matches: #{matches_id}"

        matches_id.each { |match_id| Match.create_by_serial(match_id) }

        redirect_to @account
    end

    def load_matches
        @account = Account.find(params[:id])

        matches_id = DotaApi::API.parce_matches_id(@account.steamID32)
        # puts "Matches: #{matches_id}"

        matches_id.each { |match_id| Match.create_by_serial(match_id) }

        redirect_to @account
    end

    def global_update
        heroes = DotaApi::API.get_heroes
        
        heroes.keys.each do |hero_id|
            unless Hero.exists?(hero_id: hero_id)
                hero = Hero.new(hero_id: hero_id, name_en: heroes[hero_id])
                hero.save
            end
        end

        matches_id = DotaApi::API.parce_matches_id(DEFAULT_STEAMID32)
        matches_to_save = []
        stats_to_save = []
        
        matches_id.each do |serial| 
            data, stat = DotaApi::API.parce_match(serial)
            matches_to_save.push(data)
            puts stat
            stats_to_save += stat
        end
        Match.create(matches_to_save)

        stats_to_save_res = []
        stats_to_save.each do |stat|
            stat['match'] = Match.find_by(serial: stat['match_id'])
            stats_to_save_res.push(stat)
        end
        MatchStat.create(stats_to_save_res)

        redirect_to root_path
    end
end
