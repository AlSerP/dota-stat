require "#{Rails.root}/lib/tasks/dota_api.rb"

class AccountsController < ApplicationController
    include DotaApi
    PRIME_STEAMID32 = [91737704, 85134343, 237330027, 259411999]

    def show
        @account = Account.exists?(params[:id]) ? Account.find(params[:id]) : Account.find_by(steamID32: params[:id])
        week_ago = '2023-04-22 00:00:00'

        @week_matches = @account.match_stats.where("start_time > ?", week_ago)
        @week_avg = get_avg(@week_matches)
        @global_avg = get_avg(@account.match_stats)
    end

    def update_matches
        @account = Account.exists?(params[:id]) ? Account.find(params[:id]) : Account.find_by(steamID32: params[:id])  

        if @account
            player_profile = DotaApi::API.parce_player(@account.steamID32)
            unless player_profile['personaname'] == @account.username
                @account.username = player_profile['personaname']
                puts "New name: #{@account.username} for #{@account.steamID32}"
                @account.save
            end
            @account.avatar_url = player_profile['avatarfull']
            
            unless @account.last_update
                @account.last_update = @account.get_last_match.serial
                @account.save
            end
            
            matches_id = DotaApi::API.parce_matches_id(@account.steamID32, start_from=@account.last_update)
            puts "Matches: #{matches_id}"

            matches_id.each { |match_id| matches_id.delete(match_id) if Match.find_by(serial: match_id) }

            create_matches(matches_id)

            puts "SERIAL - #{@account.last_update}"
            @account.last_update = @account.get_last_match.serial
            @account.save
            puts "SERIAL - #{@account.last_update}"
            redirect_to @account
        else
            redirect_to root_path
        end
    end

    def load_matches
        @account = Account.exists?(params[:id]) ? Account.find(params[:id]) : Account.find_by(steamID32: params[:id])  

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

        matches_id = DotaApi::API.parce_matches_id(PRIME_STEAMID32)
        print matches_id

        PRIME_STEAMID32.each do |steam_id32|
            player_profile = DotaApi::API.parce_player(steam_id32)
            account = Account.new
            account.steamID32 = steam_id32.to_i
            account.username = player_profile['personaname']
            account.save
            puts "ACCOUNT CREATED #{account.username}"
        end

        matches_to_save = []
        stats_to_save = []
        
        matches_id.each do |serial| 
            data, stat = DotaApi::API.parce_match(serial)
            matches_to_save.push(data)
            # puts stat
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

    def get_avg(match_stats)
        avg = {}
        unless match_stats.blank?
            avg[:kills] = match_stats.average(:kills).round(1)
            avg[:assists] = match_stats.average(:assists).round(1)
            avg[:deaths] = match_stats.average(:deaths).round(1)
        end
        return avg
    end

    def create_matches(matches_id)
        matches_to_save = []
        stats_to_save = []
        matches_id.each do |serial| 
            data, stat = DotaApi::API.parce_match(serial)
            matches_to_save.push(data)
            # puts stat
            stats_to_save += stat
        end
        Match.create(matches_to_save)

        stats_to_save_res = []
        stats_to_save.each do |stat|
            stat['match'] = Match.find_by(serial: stat['match_id'])
            stats_to_save_res.push(stat)
        end
        MatchStat.create(stats_to_save_res)

        return 0
    end
end
