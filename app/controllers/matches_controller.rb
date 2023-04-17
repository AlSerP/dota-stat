class MatchesController < ApplicationController
  def index()
    @matches = Match.all
  end

  def show()
    @match = Match.find params[:id]
  end

  def new()
    @match = Match.new
  end

  def create_table()
    @match = Match.new match_params

    if @match.save
      redirect_to @match
    else
      render :new, status: :unprocessable_entity
    end

    private
    def match_params()
      params.require(:match).permit(:serial, :score_radiant, :score_dire)
    end
  end
end
