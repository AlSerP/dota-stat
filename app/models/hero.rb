class Hero < ApplicationRecord
    def Hero.global_update
        heroes = DotaApi::API.get_heroes
        
        heroes.keys.each do |hero_id|
            if Hero.exists?(hero_id: hero_id)
                hero = Hero.find_by(hero_id: hero_id)
                hero.avatar_url = DotaApi::API.get_hero_image_by_id(hero_id)
            else
                hero = Hero.new(hero_id: hero_id, name_en: heroes[hero_id], avatar_url: DotaApi::API.get_hero_image_by_id(hero_id))
            end
            hero.save
        end
    end
end
