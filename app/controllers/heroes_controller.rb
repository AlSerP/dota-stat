class HeroesController < ApplicationController
    def index
        @heroes = Hero.all
    end

    def load
        
    end
end