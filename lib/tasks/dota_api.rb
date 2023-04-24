require 'uri'
require 'net/http'
require 'json'
require 'set'

module DotaApi
    HOST = "https://api.opendota.com/api/"
    I64 = 76561197960265728
    class APIClient
        JSON_FILE = 'match.json'
        HEROES_FILE = 'heroes.json'
        MATCHES_FILE = 'matches.json'
    
        def initialize
            @heroes = {}
            parce_heroes()
        end
    
        def save_to_json(text, file=JSON_FILE)
            # puts text
            File.open(file, 'w+') {|f| f.write text.force_encoding('utf-8') }
            # puts 'File saved'
        end
    
        def download_to_json(path, file=JSON_FILE, to_save=false)
            uri = URI("#{HOST}#{path}")
            response = get uri
            save_to_json response, file if to_save
            return JSON.load response 
        end
    
        def download_match(match_serial)
            return download_to_json "matches/#{match_serial}"
        end
        
        def download_player(steam_id32)
            return download_to_json "players/#{steam_id32}"
        end

        def download_heroes
            return download_to_json "heroes", HEROES_FILE
        end
    
        def download_matches(steam_id32)
            return download_to_json "players/#{steam_id32}/matches", MATCHES_FILE
        end
        
        def id32_to_id64(steam_id32)
            return steam_id32 + I64
        end

        def id64_to_id32(steam_id64)
            return steam_id64 - I64
        end

        def post_refresh(steam_id32)
            uri = URI("#{HOST}/players/#{steam_id32}/refresh")
            
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true
            
            request = Net::HTTP::Post.new(uri.path)
    
            response = https.request(request)
    
            # puts response
        end
    
        def get(uri)
            response = Net::HTTP.get(uri)
            # puts "Got response from #{uri}"
    
            return response
        end
    
        def parce_heroes
            file = File.open HEROES_FILE
            data = JSON.load file
            file.close
    
            if data.length != 0
                data.each { |hero| @heroes[hero['id']] = hero['localized_name'] }
            else
                puts 'NO HEROES INFO'
            end
        end
    
        def parce_match(match_serial)
            data = download_match(match_serial)
            players = []
            data['start_time'] = Time.at(data['start_time']) if data['start_time']
            data['score_dire'] = data['dire_score']
            data['score_radiant'] = data['radiant_score']
            data['start_time'] = Time.at(data['start_time']) if data['start_time']
            data['serial'] = match_serial

            begin
            data['players'].each do |player|
                player['networce'] = player['net_worth']
                
                player['start_time'] = Time.at(player['start_time'])
                player['hero'] = Hero.find_by(hero_id: player['hero_id'])

                if Account.exists?(steamID32: player['account_id'])
                    player['account'] = Account.find_by(steamID32: player['account_id'])
                elsif player['account_id']
                    account = Account.new(steamID32: player['account_id'])
                    account_data = parce_player(player['account_id'])
                    if account_data
                        account.username = account_data['personaname'] if account_data['personaname']
                    else
                        account.username = 'Аноним'
                    end
                    account.save
                    player['account'] = account
                else
                    account = Account.new(steamID32: 0)
                    account.username = 'Неизвестен'
                    account.save
                    player['account'] = account
                end
                player['match_id'] = match_serial
                players.push(player.slice('kills', 'deaths', 'assists', 'last_hits', 'denies', 'networce', 'start_time', 'hero', 'account', 'match_id'))
            end
            rescue
                puts "-------------ERROR MATCH #{match_serial}"
            end
            puts players
            return data.slice('serial', 'score_dire', 'score_radiant', 'start_time', 'duration'), players
        end

        def parce_matches_id(steam_id32, start_from=0)
            def get_matches_id(account_id, start_from)
                matches_set = Set[]
                data = download_matches(account_id)
                data.each { |match_info| matches_set.add(match_info['match_id']) if match_info['match_id'] > start_from }
                return matches_set
            end

            matches = Set[]
            if steam_id32.class == [].class
                steam_id32.each do |id32|
                    matches |= get_matches_id(id32, start_from)
                end
            else
                matches |= get_matches_id(steam_id32, start_from)
            end

            return matches.to_a
        end
        
        def parce_player(steam_id32)
            data = download_player(steam_id32)
            # puts data
            return data['profile']
        end

        def get_hero_image_by_id(hero_id)
            hero_name = @heroes[hero_id].downcase
            hero_name.gsub!('-', '')
            hero_name.gsub!(' ', '_')
            url = "http://cdn.dota2.com/apps/dota2/images/heroes/#{hero_name}_lg.png"
            return url
        end
    
        def get_hero_images
            images = {}
            @heroes.keys.each do |hero_id|
                images[hero_id] = get_hero_image_by_id hero_id
            end
            return images
        end
    
        def get_heroes
            return @heroes
        end
    end

    API = APIClient.new
end

if __FILE__ == $0
    API.parce_match
end
