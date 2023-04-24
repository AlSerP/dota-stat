class Account < ApplicationRecord
    has_many :match_stats
    validates :steamID32, uniqueness: true

    def get_last_match
        Match.order(:serial).reverse.each do |match|
            match.match_stats.each do |stat|
                return match if stat.account == self
            end
        end
        return nil
    end
end
