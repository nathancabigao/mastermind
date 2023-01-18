# frozen-string-literal: true

# Constants for the game
MAX_TURNS = 12
HOLES = 4
PEGS = 6
# Constants for code checking, remainder guesses and remainder code
CODE = 0
GUESS = 1

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
    puts "\nIn this game, the codemaster sets a code in #{HOLES} holes which can contain #{PEGS} different pegs each (1-#{PEGS})."
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
    # Decide between codebreaker or codemaster
    mode_select
  end

  def mode_select
    puts "\nChoose a game mode! Enter 1 to be codebreaker, enter 2 to be codemaster."
    chosen_game_mode = gets.chomp
    play_codebreaker if chosen_game_mode == '1'
    play_codemaster if chosen_game_mode == '2'
    return if %w[1 2].include?(chosen_game_mode)

    puts 'Invalid selection. Try again.'
    mode_select
  end

  # Sets up a gameplay loop for playing as codebreaker.
  def play_codebreaker
    write_code(computer_set_code)
    win = false
    until win || @turn > 12
      guess = player_guess
      generate_guess_key(guess)
      display_guess_message(guess)
      @turn += 1 unless (win = (guess == @code))
    end
    display_end_message(win)
  end

  def play_codemaster
    return
  end

  # Sets the code for the game
  def write_code(code)
    (1..HOLES).each { |hole| @code << code[hole - 1] }
  end

  # Randomizes a code for the game
  def computer_set_code
    code = []
    (1..HOLES).each { code << rand(1..PEGS) }
    code
  end

  # Receives the guess from the codebreaker, returns the guess upon success.
  def player_guess
    valid = false
    until valid
      guess = []
      puts "\nGuess \##{@turn}:"
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

  # Given a guess, generates the key indicating how good the guess was.
  def generate_guess_key(guess)
    @key = [] # reset key from last turn
    # New 2D array for remaining code/guesses, remainders[0]->remainders[CODE] and remainders[1]->remainders[GUESS]
    remainders = check_perfect_guesses(guess)
    return if remainders[GUESS].size.zero? # guard clause, don't check partial matches if the guess matches the code.

    check_partial_guesses(remainders)
    add_misses_to_key
  end

  # Given a guess, updates the key with any PERFECTs and returns a 2D array with remaining guesses/code that are not perfect.
  def check_perfect_guesses(guess)
    remainders = [[], []]
    (1..HOLES).each do |hole|
      if guess[hole - 1] == @code[hole - 1]
        @key << 'PERFECT'
      else
        remainders[CODE] << @code[hole - 1]
        remainders[GUESS] << guess[hole - 1]
      end
    end
    remainders
  end

  # Given the remaining imperfect guesses/code pegs, give hints whenever a guessed peg exists but is imperfect.
  def check_partial_guesses(remainders)
    (1..remainders[GUESS].size).each do |rem_guess|
      # Guard clause, if that peg is wrong, do nothing. Otherwise, put an EXISTS.
      next unless remainders[CODE].include?(remainders[GUESS][rem_guess - 1])

      @key << 'EXISTS'
      # Remove an occurrence of that peg, to avoid excess EXISTS
      remainders[CODE].delete_at(remainders[CODE].find_index(remainders[GUESS][rem_guess - 1]))
    end
  end

  # Adds '-' to fill in as "misses" in the key
  def add_misses_to_key
    misses = HOLES - @key.size
    misses.times { @key << '-' }
  end

  def display_guess_message(guess)
    puts "You guessed: #{guess.inspect}, Key: #{@key}"
  end

  def display_end_message(win)
    puts "\nThe code was #{@code.inspect}!"
    if win
      puts "You win! You cracked the code in #{@turn} turns!"
    else
      puts "You lose. You did not crack the code within #{MAX_TURNS} turns."
    end
  end
end

game = Game.new
game.play
