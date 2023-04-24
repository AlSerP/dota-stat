# require "#{Rails.root}/lib/tasks/dota_api.rb"

class MatchesController < ApplicationController

  def index
    @matches = Match.all
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
end
