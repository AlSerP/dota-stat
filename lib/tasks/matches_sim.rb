module MatchSim
    RANDOM = Random.new
    POS_COEF = {
        1 => 1.2,
        2 => 1.2,
        3 => 0.9,
        4 => 0.7,
        5 => 0.7
    }
    K = 35  # ELO multiplier

    def calc_elo(elo1, elo2, is_win)
        ea = 1/(1 + 10 ** ((elo2-elo1)/400))
        ra = K * ((is_win ? 1 : 0) - ea)
        return ra
    end

    def normalize(x, min, max)
        return (x - min) / (max - min)
    end

    class Team
        attr_reader :name

        def initialize(name, players)
            @name = name
            @players = players
        end
        def get_player(pos)
            return @players[pos + 1]
        end
        def get_mean_elo
            mean_elo = 0.0
            @players.each {|player| mean_elo += player.elo}
            mean_elo /= 5
            return mean_elo 
        end

        def create_match_stat(opponent_team)
            team_stats = []
            for i in 0..4 do
                team_stats.append(PlayerScore.new(@players[i], opponent_team))
            end
            return team_stats
        end

        def each(&block)
            @players.each(&block)
        end

        def to_s
            return "#{@name}(#{get_mean_elo})"
        end

        def to_json(*options)
            as_json(*options).to_json(*options)
        end
    end

    class Player
        attr_reader :elo, :pos, :name
        def initialize(name, pos, elo=1000)
            @name = name
            @elo = elo
            @pos = pos
        end
        def update_elo(elo_diff)
            @elo += elo_diff
        end
        def to_s
            return "#{@name} (#{elo})"
        end
    end

    class PlayerScore
        attr_reader :coef, :player
        def initialize(player, opponent_team)
            @player = player

            @kills = 0
            @assists = 0
            @deaths = 0
            
            @pos = player.pos

            opponent_sum_elo = 0
            opponent_team.each {|player| opponent_sum_elo += player.elo }
            opponent_mean_elo = opponent_sum_elo.to_f / 2 

            @coef = player.elo.to_f / opponent_mean_elo * 0.5 
        end
        def kill(player)
            @kills += 1
            player.die
        end
        def die
            @deaths += 1
        end
        def assisted
            @assists += 1
        end
        def to_s
            "#{@player.name}  #{@kills}/#{@deaths}/#{@assists}"
        end
        def get_pos_coef
            return @coef * POS_COEF[@pos]
        end

        def get_stat_coef
            if @pos == 1 or @pos == 2
                pos_modif = (@kills * 1.5 + @assists * 0.5 - @deaths * 2.5)
            elsif @pos == 3
                pos_modif = (@kills * 1 + @assists * 0.5 - @deaths * 1.5)
            else 
                pos_modif = (@kills * 0.5 + @assists * 1 - @deaths * 2)
            end
            return pos_modif
        end

        def summarize(is_win, min_score, max_score, mean_opponent_elo)
            if is_win
                @player.update_elo(calc_elo(@player.elo, mean_opponent_elo, is_win) * (normalize(get_stat_coef, min_score, max_score) - 0.2))
            else
                @player.update_elo(calc_elo(@player.elo, mean_opponent_elo, is_win) * (0.8 - normalize(get_stat_coef, min_score, max_score)))
            end
        end
    end

    def calc_team_coefficient(team)
        team_c = 1
        team.each do |player| 
            team_c += player.coef
        end
        return team_c
    end

    def sim_fight(radiant, dire)
        score = [0, 0]
        dire_up = dire
        for player_r_index in 0..(radiant.length-1) do
            player_radiant = radiant[player_r_index]
            for player_d_index in 0..(dire.length-1) do
                player_dire = dire[player_d_index]
                
                if player_dire != -1
                    result = RANDOM.rand
                    if result > (player_dire.get_pos_coef / player_radiant.get_pos_coef * 0.5)
                        score[0] += 1
                        dire[player_d_index] = -1
                        player_radiant.kill(player_dire)
                        radiant.each { |player| player.assisted if player != -1 and player != player_radiant }
                    else
                        score[1] += 1
                        player_dire.kill(player_radiant)
                        radiant[player_r_index] = -1
                        dire.each { |player| player.assisted if player != -1 and player != player_dire }
                        break
                    end
                end
            end
        end
        return score
    end

    def decide_fight_type(minute)
        fight_type_prob = {
            0 => {
                15 => 0,
                35 => 0.2,
                80 => 0.05
            },
            1 => {
                15 => 0.6,
                35 => 0.3,
                80 => 0.20
            },
            2 => {
                15 => 0.8,
                35 => 0.5,
                80 => 0.4
            },
            3 => {
                15 => 1.0,
                35 => 0.7,
                80 => 0.65
            },
            4 => {
                15 => 1.0,
                35 => 0.9,
                80 => 0.75
            },
            5 => {
                15 => 1.0,
                35 => 1.0,
                80 => 1.0
            }
        }

        game_stage = 15
        if minute <= 15
            game_stage = 15
        elsif minute <= 35
            game_stage = 35
        else
            game_stage = 80
        end

        res = RANDOM.rand(0..5)
        for i in 0..5 do
            if res <= fight_type_prob[i][game_stage]
                return i
            end
        end
        return 0
    end

    def sim_minute!(radiant, dire, minute, score)
        fight_type = decide_fight_type(minute)

        fighters_r = []
        fighters_d = []
        i = 0
        while i < fight_type do
            player_radiant = RANDOM.rand(0..4)
            while fighters_r.include?(player_radiant)
                player_radiant = RANDOM.rand(0..4)
            end
            fighters_r.append(player_radiant)

            player_dire = RANDOM.rand(0..4)
            while fighters_d.include?(player_dire)
                player_dire = RANDOM.rand(0..4)
            end
            fighters_d.append(player_dire)

            i += 1
        end

        fighters_r_coef = []
        fighters_d_coef = []

        for i in 0..(fighters_r.length - 1)
            fighters_r_coef[i] = radiant[fighters_r[i]]
            fighters_d_coef[i] = dire[fighters_d[i]]
        end

        res = sim_fight(fighters_r_coef, fighters_d_coef)
        score[0] += res[0]
        score[1] += res[1]

        # puts("Munite #{minute} | Teams: #{fighters_r} - #{fighters_d} | #{res}")
    end

    def sim_match(team1, team2, console=false)
        # Preparation
        radiant = team1.create_match_stat(team2)
        dire = team2.create_match_stat(team1)

        radiant_win = false
        radiant_c = calc_team_coefficient(radiant)
        dire_c = calc_team_coefficient(dire)

        result = RANDOM.rand
        match_time = [RANDOM.rand(20..80), RANDOM.rand(0..59)] # Minutes:Seconds

        score = [0, 0]
        for minute in 0..match_time[0]
            sim_minute!(radiant, dire, minute, score)
        end
        if score[0] == 0 and score[1] == 0
            return sim_match(team1, team2)
        end

        score_c = (score[0] == 0 or score[1] == 0) ? 1 : score[1].to_f / score[0]
        teams_c = dire_c / radiant_c
        match_coef = score_c * teams_c * 0.5  # Probability of radiant win
        radiant_win = true if result > match_coef

        # Elo results
        max_stat = -200
        min_stat = 200
        for i in 0..4 do
            radiant_player_stat = radiant[i].get_stat_coef
            max_stat = radiant_player_stat if radiant_player_stat > max_stat
            min_stat = radiant_player_stat if radiant_player_stat < min_stat

            dire_player_stat = dire[i].get_stat_coef
            max_stat = dire_player_stat if dire_player_stat > max_stat
            min_stat = dire_player_stat if dire_player_stat < min_stat
        end

        for i in 0..4 do
            radiant[i].summarize(radiant_win, min_stat, max_stat, team2.get_mean_elo)
            dire[i].summarize(!radiant_win, min_stat, max_stat, team1.get_mean_elo)
        end

        if console
            puts("Score - #{score[0]}:#{score[1]} " + (radiant_win ? '(Radiant win!)' : '(Dire win!)'))
            puts("per #{match_time[0]}:#{match_time[1]} mins")
            puts("Radiant-----------#{team1}")
            radiant.each do |player|
                puts(player.to_s)
            end
            puts("Dire-----------#{team2}")
            dire.each do |player|
                puts(player.to_s)
            end
            puts("Match result #{result} with match coefficient #{match_coef}, score coefficient #{score_c}, teams coefficient #{teams_c}", "Score - #{score}")
        end

        return {radiant_win: radiant_win, time: match_time, score: score}
    end

    def sim_teams(team1, team2, matches_num=100)
        results = 0.0
        for i in 1..matches_num do
            results += RANDOM.rand > 0.5 ? (sim_match(team1, team2)[:radiant_win] ? 1 : 0) : (sim_match(team2, team1)[:radiant_win] ? 0 : 1)
        end
        puts(team1.get_mean_elo)
        puts(team2.get_mean_elo)
        return results / matches_num
    end

    def sim_ligue(teams, matches_num=100)
        for i in 1..matches_num do
            opponents = teams.sample(2)
            RANDOM.rand > 0.5 ? sim_match(opponents[0], opponents[1]) : sim_match(opponents[1], opponents[0])
        end

        puts RANDOM.rand > 0.5 ? sim_match(teams[0], teams[1], true) : sim_match(teams[1], teams[0], true)

        teams.each do |team|
            puts team, '---'
            team.each {|player| puts player}
            puts("===============")
        end
    end
end

# team1 = Team.new('ЯВМЕ', [Player.new('Илья', 1, 1000), Player.new('Гоша', 2, 1000), Player.new('Максим', 3, 1000), Player.new('Артем', 4, 1000), Player.new('Никита', 5, 1000)])
# team2 = Team.new('Team Spirit', [Player.new('Yatoro', 1, 1000), Player.new('Larl', 2, 1000), Player.new('Collapse', 3, 1000), Player.new('Mira', 4, 1000), Player.new('Miposhka', 5, 1000)])
# team3 = Team.new('BetBoom Team', [Player.new('Nightfall', 1, 1000), Player.new('gpk', 2, 1000), Player.new('Pure', 3, 1000), Player.new('Save', 4, 1000), Player.new('TORONTOTOKYO', 5, 1000)])
# team4 = Team.new('9Pandas', [Player.new('RAMZES666', 1, 1000), Player.new('kiyotaka', 2, 1000), Player.new('yuragi', 3, 1000), Player.new('Antares', 4, 1000), Player.new('Solo', 5, 1000)])
# team5 = Team.new('B8', [Player.new('StoneBank', 1, 1000), Player.new('Dendi', 2, 1000), Player.new('Funn1k', 3, 1000), Player.new('CTOMAHEH1', 4, 1000), Player.new('Lodine', 5, 1000)])

# teams = [team1, team2, team3, team4, team5]
# # puts(team1.to_json)

# # puts("Radiant win - #{sim_match(team1, team2, true)}")
# # puts(sim_teams(team1, team2, 100))
# # team1.each {|player| puts player}
# # puts("-------------------")
# # team2.each {|player| puts player}

# sim_ligue(teams, 100)