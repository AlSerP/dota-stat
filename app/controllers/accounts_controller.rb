require "#{Rails.root}/lib/tasks/dota_api.rb"

class AccountsController < ApplicationController
    include DotaApi

    def show
        @account = Account.find(params[:id])
    end

    def update_matches
        @account = Account.find(params[:id])

        matches_id = DotaApi::API.parce_matches_id(@account.steamID32, start_from=@account.get_last_match.serial)
        puts "Matches: #{matches_id}"

        matches_id.each { |match_id| Match.create_by_serial(match_id) }

        redirect_to @account
    end

    def load_matches
        @account = Account.find(params[:id])

        matches_id = DotaApi::API.parce_matches_id(@account.steamID32)
        puts "Matches: #{matches_id}"

        matches_id.each { |match_id| Match.create_by_serial(match_id) }

        redirect_to @account
    end
end
