require "#{Rails.root}/lib/tasks/dota_api.rb"

class Match < ApplicationRecord
    include DotaApi
    has_many :match_stats, dependent: :destroy
    validates :serial, presence: true, uniqueness: true
    validates :score_radiant, presence: true
    validates :score_dire, presence: true

    def Match.create_by_serial(serial)
        if Match.exists?(serial: serial)
            return nil
        end
        match = Match.new(serial: serial)
        data = DotaApi::API.parce_match(match.serial)

        match.score_radiant = data['dire_score']
        match.score_dire = data['radiant_score']

        if match.save
            data['players'].each do |player|
                match_stat = match.match_stats.create()
                match_stat.kills = player['kills']
                match_stat.deaths = player['deaths']
                match_stat.assists = player['assists']
                match_stat.last_hits = player['last_hits']
                match_stat.denies = player['denies']
                match_stat.networce = player['net_worth']
                match_stat.networce = player['net_worth']
                match_stat.hero = Hero.find_by(hero_id: player['hero_id'])

                if Account.exists?(steamID32: player['account_id'])
                    match_stat.account = Account.find_by(steamID32: player['account_id'])
                elsif player['account_id']
                    account = Account.new(steamID32: player['account_id'])
                    account_data = DotaApi::API.parce_player(player['account_id'])
                    if account_data['personaname']
                    account.username = account_data['personaname']
                    end
                    account.save
                    match_stat.account = account
                end

                match_stat.save
            end
            return match
        end

        return nil
    end
end
