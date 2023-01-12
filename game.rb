# frozen-string-literal: true

# Constants
MAX_TURNS = 12
HOLES = 4
PEGS = 6

# Create and play games of Mastermind
class Game
  def initialize
    @turn = 1
    @code = []
    @key = []
  end

  # Welcome messages for the player
  def welcome
    puts 'Welcome to Mastermind!'
    puts "In this game, the codemaster sets a code in #{HOLES} holes which can contain #{PEGS} different pegs each (1-#{PEGS})."
    puts "The codebreaker will get #{MAX_TURNS} tries to guess the code by guessing 1-#{PEGS} for each one of the #{HOLES} holes."
    puts 'For each turn, the codemaster will return a key, denoting how close their guess was to the actual result:'
    puts '- If a peg was correctly guessed (that hole contained that peg number), a PERFECT will be returned in the key.'
    puts '- If a peg is contained in the code but is not in the correct hole, an EXISTS will be returned in the key.'
    puts '- Otherwise, there will be nothing returned in the key (-).'
    puts "The game ends in victory for the codebreaker if they crack the code in #{MAX_TURNS} turns, otherwise it is a win for the codemaster."
  end

  # Starts the core gameplay loop
  def play
    welcome
    @code = [1, 1, 1, 1]
    win = false
    # write_code(computer_generate_code)
    until win || @turn > 12
      guess = player_guess
      win = (guess == @code)
      display_guess_message(guess)
      @turn += 1 unless win
    end
    display_end_message(win)
  end

  # Sets the code for the game
  def write_code(code)
    (1..HOLES).each { |hole| @code << code[hole - 1] }
  end

  # Randomizes a code for the game
  def computer_set_code
    code = []
    (1..HOLES).each { code << random_peg }
    code
  end

  # Randomizes a peg
  def random_peg
    rand(1..PEGS)
  end

  # Receives the guess from the codebreaker, returns the guess upon success.
  def player_guess
    valid = false
    until valid
      guess = []
      puts "Guess \##{@turn}:"
      (1..HOLES).each { guess << gets.to_i }
      valid = valid_guess?(guess)
      puts "Invalid guess, please try again. Use pegs 1-#{PEGS} only." unless valid
    end
    guess
  end

  # Takes in a code guess as an array, and evaluates if its input is valid (correct size and valid pegs used)
  def valid_guess?(guess)
    guess.size == HOLES && guess.all? { |num| num.is_a?(Integer) && num >= 1 && num <= PEGS }
  end

  def display_guess_message(guess)
    puts "You guessed: #{guess.inspect}"
  end

  def display_end_message(win)
    if win
      puts "You win! You cracked the code in #{@turn} turns!"
    else
      puts "You lose. You did not crack the code within #{MAX_TURNS} turns."
    end
  end
end

game = Game.new
game.play
