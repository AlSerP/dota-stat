# require "#{Rails.root}/lib/tasks/matches_sim.rb"

class ProMatch < ApplicationRecord
    # include MatchSim

    def ProMatch.simnulate_match(team1, team2)
        # team1.players
        # sim_team_1 = MatchSim::Team.new(team1.name, [MatchSim::Player.new(team1.players[0], 1, 1000), Player.new('Гоша', 2, 1000), Player.new('Максим', 3, 1000), Player.new('Артем', 4, 1000), Player.new('Никита', 5, 1000)])
        # sim_team_2 = MatchSim::Team.new('ЯВМЕ', [Player.new('Илья', 1, 1000), Player.new('Гоша', 2, 1000), Player.new('Максим', 3, 1000), Player.new('Артем', 4, 1000), Player.new('Никита', 5, 1000)])

    end
end
