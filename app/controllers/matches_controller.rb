require "#{Rails.root}/lib/tasks/dota_api.rb"

class MatchesController < ApplicationController
  include DotaApi

  def index
    @matches = Match.all
  end

  def show
    @match = Match.find(params[:id])
    puts Match.column_names
  end

  def new
    @match = Match.new
  end

  def create
    @match = Match.new(match_params)
    data = DotaApi::API.parce_match(@match.serial)

    @match.score_radiant = data['dire_score']
    @match.score_dire = data['radiant_score']

    if @match.save
      data['players'].each do |player|
        match_stat = @match.match_stats.create()
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
          account.username = account_data['personaname']
          account.save
          match_stat.account = account
        end

        match_stat.save
      end

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
