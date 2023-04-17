require 'uri'
require 'net/http'
require 'json'

HOST = "https://api.opendota.com/api/"
a = 76561198045400071
I64 = 76561197960265728
I32 = 85134343
'https://api.opendota.com/api/players/85134343/refresh'

class Client
    JSON_FILE = 'match.json'
    HEROES_FILE = 'heroes.json'
    MATCHES_FILE = 'matches.json'

    def initialize()
        @heroes = {}
        # post_refresh()
        parce_matches()
        # get_heroes()
    end

    def save_to_json(text, file=JSON_FILE)
        File.open(file, 'w+') {|f| f.write text }
        puts 'File saved'
    end

    def get_match(match_id)
        uri = URI("https://api.opendota.com/api/matches/#{match_id}")
        response = get uri

        save_to_json response
    end

    def get_heroes()
        uri = URI("https://api.opendota.com/api/heroes")
        response = get uri
        save_to_json response, HEROES_FILE 
    end

    def get_matches()
        # user_id32 = 85134343
        user_id64 = 76561198052003432
        user_id32 = user_id64 - I64
        uri = URI("https://api.opendota.com/api/players/#{user_id32}/matches")

        response = get uri
        save_to_json response, MATCHES_FILE
    end

    def post_refresh()
        # user_id = 85134343
        user_id64 = 76561198052003432
        user_id32 = user_id64 - I64
        puts user_id32
        uri = URI("https://api.opendota.com/api/players/#{user_id32}/refresh")
        
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        
        request = Net::HTTP::Post.new(uri.path)

        response = https.request(request)

        puts response
    end

    def get(uri)
        response = Net::HTTP.get(uri) # => String
        puts "Got response from #{uri}"

        return response
    end

    def parce_heroes()
        file = File.open HEROES_FILE
        data = JSON.load file
        file.close()

        if data.length != 0
            data.each { |hero| @heroes[hero['id']] = hero['localized_name'] }
        else
            puts 'NO HEROES INFO'
        end
    end

    def parce_match()
        file = File.open JSON_FILE
        data = JSON.load file
        file.close()

        puts "Match ##{data['match_id']}"
        puts '-----------------------------------'
        puts "Score: #{data['radiant_score']} - #{data['dire_score']}"
        puts data['radiant_win'] ? 'Radiant win' : 'Dire win'
        puts '-----------------------------------'
        puts "Game duration: #{data['duration'].to_f/60} mins"
        puts "Competitive match" if data['game_mode'] == 22
        
        puts '-----------------------------------'
        data['players'].each do |player|
            puts @heroes[player['hero_id']]
            puts "KDA - #{player['kills']}/#{player['deaths']}/#{player['assists']}"
            puts "Creep Stat #{player['last_hits']}/#{player['denies']}"
            puts '-----------------------------------'
        end 
    end
    def parce_matches()
        parce_heroes()
        file = File.open MATCHES_FILE
        data = JSON.load file
        file.close()

        data.each do |match|
            get_match(match['match_id'])
            parce_match()
            break
        end 
    end
end

if __FILE__ == $0
    app = Client.new
end
