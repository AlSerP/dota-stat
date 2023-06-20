# require_relative 'opendota'
require "#{Rails.root}/lib/tasks/dota_api.rb"

class HeroesController < ApplicationController
    include DotaApi
    # api = DotaApi::API.new
    def index
        @heroes = Hero.all
    end

    def load
        Hero.global_update

        redirect_to heroes_path
    end
end
