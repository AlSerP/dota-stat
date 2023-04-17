class MatchesController < ApplicationController
  def index
    @matches = Match.all
  end

  def show
    @match = Match.find(params[:id])
  end

  def new
    @match = Match.new
  end

  def create
    @match = Match.new(match_params)

    if @match.save
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
    params.require(:match).permit(:serial, :score_radiant, :score_dire)
  end
end
