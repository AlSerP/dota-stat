class ProMatchesController < ApplicationController
    include DotaApi
    def index
        @matches = ProMatch.all.first(10)
        # @best = get_best(Account::PRIME_STEAMID32)
    end

    def show
        @match = ProMatch.find(params[:id])
    end

    def new
        @match = ProMatch.new
    end

    def create
        puts match_params[:serial]
        @match = ProMatch.create_by_serial(match_params[:serial])
        if @match
            redirect_to @match
        else
            render :new, status: :unprocessable_entity
        end
    end
end
