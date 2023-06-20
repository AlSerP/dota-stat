# require "#{Rails.root}/lib/tasks/dota_api.rb"

class MatchesController < ApplicationController
    include DotaApi
    def index
        @matches = Match.all.first(10)
        @best = get_best(Account::PRIME_STEAMID32)
    end

    def show
        @match = Match.find(params[:id])
        # puts @match.match_stats.all
    end

    def new
        @match = Match.new
    end

    def create
        # @match = ObjCreator::create_match_by_serial(match_params[:serial])
        puts match_params[:serial]
        @match = Match.create_by_serial(match_params[:serial])
        if @match
        redirect_to @match
        else
        render :new, status: :unprocessable_entity
        end
    end

    def edit
        @match = Match.find(params[:id])
    end

    def update
        @match = Match.find(params[:id])

        if @match.update(match_params)
        redirect_to @match
        else
        render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @match = Match.find(params[:id])
        @match.destroy

        redirect_to root_path, status: :see_other
    end

    private
    def match_params
        # params.require(:match).permit(:serial, :score_radiant, :score_dire)
        params.require(:match).permit(:serial)
    end

    def get_best(players_id32)
        best = {kills: [0, nil], assists: [0, nil], deaths: [100, nil]}
        players_id32.each do |players_id32|
            player = Account.find_by(steamID32: players_id32)
            if player
                kills = player.match_stats.average(:kills).round(1)
                if kills > best[:kills][0]
                    best[:kills][0] = kills 
                    best[:kills][1] = player 
                end

                assists = player.match_stats.average(:assists).round(1)
                if assists > best[:assists][0]
                    best[:assists][0] = assists 
                    best[:assists][1] = player 
                end

                deaths = player.match_stats.average(:deaths).round(1)
                if deaths < best[:deaths][0]
                    best[:deaths][0] = deaths 
                    best[:deaths][1] = player 
                end
            end
        end
        return best
    end
end
