class Display
  def self.print(message)
    puts
    puts message
  end

  def self.print_and_prompt(message)
    puts
    puts message
    gets.chomp
  end

  def self.show_results(players)
    puts "******* Final Results *****"
    players.each do |player|
      puts "#{player.name} | #{player.total_points}"
    end
  end
end


class DiceSet
  attr_reader :non_scoring_dice
  attr_reader :roll_score


  def initialize(num_dice_to_roll)
    @num_dice_to_roll = num_dice_to_roll
  end

  def calculate_score(roll_points)
    @roll_score = 0
    @scores = Hash.new(0)
    @scoring_dice = 0
    @non_scoring_dice = 0 

    roll_points.each do |n|
      @scores[n] += 1
    end
    puts "scores are \n"
    puts @scores
    @scores.each do |key, value|
      #Score the triplets
      if value >= 3
        @roll_score += key == 1 ? 1000 : key * 100 
        @scoring_dice += 3
        value -= 3
      end
      #if there is a single one that cannot be part of the triplets.
      if key == 1
        @roll_score += value * 100
        @scoring_dice += value
      end
      #if there is a single one that cannot be part of the triplets.
      if key == 5
        @roll_score += value * 50
        @scoring_dice += value
      end
    end

    puts "scoring dice - score",@scoring_dice, @roll_score 
    @non_scoring_dice = @num_dice_to_roll - @scoring_dice
    @roll_score
  end

  def roll
    calculate_score(@num_dice_to_roll.times.map {|n| rand(6) + 1 })
  end

  def no_scoring_dice?
    @scoring_dice == 0
  end

  def all_scoring_dice?
    @scoring_dice == @num_dice_to_roll
  end
end

class Players
  attr_reader :name
  attr_reader :total_points
  attr_reader :player_done 
  def initialize(name)
    @name = name
    @total_points = 0
    @in_the_game = false
    @player_done = false
  end

  def play_turn
    points_in_roll = 0
    points_in_turn = 0

    num_dice_to_roll = 5
    message = "<&&&&&&& #{@name.upcase }'s turn. Total Points till now #{@total_points} &&&&&&>"
    message += "YOU need to score 300 points to start the game." if !@in_the_game
    end
    Display.print(message)

    loop do 
      dice = DiceSet.new(num_dice_to_roll)
      dice.roll
      points_in_roll += dice.roll_score
      points_in_turn += points_in_roll

      if dice.no_scoring_dice?
        message = "Hard Luck! Your turn is over since you rolled no scoring dice."
        Display.print(message)
        break
      elsif dice.all_scoring_dice?
        num_dice_to_roll = 5 #SInce he scored on all dice.
        message = "Wow. All dice scored. You scored #{points_in_roll} in this roll. Your turn points are #{points_in_turn}. You can roll 5 dice now. Do you want to continues?(y/n)"
        response = Display.print_and_prompt(message)
      else
        num_dice_to_roll = dice.non_scoring_dice
        message = "You scored #{points_in_roll} in this roll. Your turn points are #{points_in_turn}. You can roll #{num_dice_to_roll} dice now. Do you want to continues?(y/n)"
        response = Display.print_and_prompt(message)
      end

      if ["n", "no", "na"].include? response.downcase
        if !@in_the_game
          if points_in_turn < GameController::MIN_POINTS_TO_QUALIFY
            points_in_turn = 0
          else
            @in_the_game = true;
          end
        end

        @total_points += points_in_turn

        if @total_points >= GameController::POINTS_TO_GO_FINAL
          @player_done = true
        end
        message = "You earned #{points_in_turn} in this turn. Your total points tally is #{@total_points}"
        Display.print(message)
        break
      end
    end 
  end
end

#This is the main controller class
class GameController
  TOTAL_DICE_IN_PLAY     = 5
  MIN_POINTS_TO_QUALIFY  = 300
  POINTS_TO_GO_FINAL = 3000

  def initialize
    @players = []
    @round = 1
    @last_round = false

    play_game
  end


  def get_players 
    message = "Enter Player names separated with comma."
    players = Display.print_and_prompt(message)
    players = players.strip.split(/\s*,\s*/)
    @players = players.map { |name| Players.new(name)}
    puts @players
  end

  def play_game
    get_players

    until @last_round

      message = "***************** Round #{@round} ****************"
      Display.print(message)
      @players.each do |player|
        player.play_turn

        if player.player_done
          @last_round = true
          break
        end
      end
      @round += 1
    end

    # Play last round.
    if @last_round
      message = "******* LAST ROUND. GO.GO.GO*****"
      Display.print(message)

      @players.each do |player|
        unless player.player_done
          player.play_turn
        end
      end
    end

    Display.show_results(@players)
  end
end

GameController.new


