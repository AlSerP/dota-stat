# require_relative 'opendota'
require "#{Rails.root}/lib/tasks/dota_api.rb"

class HeroesController < ApplicationController
    include DotaApi
    # api = DotaApi::API.new
    def index
        @heroes = Hero.all
        @images = DotaApi::API.get_hero_images
    end

    def load
        heroes = DotaApi::API.get_heroes
        puts Hero.find_by(hero_id: 10).name_en
        heroes.keys.each do |hero_id|
        unless Hero.exists?(hero_id:)
            hero = Hero.new(hero_id:, name_en: heroes[hero_id])
            hero.save
        end
    end

    redirect_to heroes_path
    end
end
