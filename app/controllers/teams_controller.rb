class TeamsController < ApplicationController
    def index
        @teams = Team.all
    end

    def show
        @team = Team.find(params[:id])
    end

    def new
        @team = Team.new
    end

    def create
        if not Team.exists?(name: team_params[:name])
            @team = Team.new(team_params)
            if @team.save
                redirect_to @team
            else
                render :new, status: :unprocessable_entity
            end
        end
    end

    private
    def team_params
        # params.require(:match).permit(:serial, :score_radiant, :score_dire)
        params.require(:team).permit(:name)
    end
end
