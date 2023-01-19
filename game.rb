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
    @fg_digits = []
    @perms = []
  end

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

  def play
    welcome
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

  def play_codebreaker
    write_code(computer_set_code)
    win = false
    until win || @turn > 12
      guess = player_guess
      generate_guess_key(guess)
      display_guess_message(guess)
      @turn += 1 unless (win = (guess == @code))
    end
    display_end_message(win, 0)
  end

  def play_codemaster
    write_code(player_set_code)
    win = false
    until win || @turn > 12
      sleep 0.5
      guess = computer_guess(guess)
      generate_guess_key(guess)
      display_guess_message(guess)
      @turn += 1 unless (win = (guess == @code))
    end
    display_end_message(win, 1)
  end

  def write_code(code)
    (1..HOLES).each { |hole| @code << code[hole - 1] }
  end

  def player_set_code
    valid = false
    until valid
      code = []
      puts "\nEnter your code:"
      (1..HOLES).each { code << gets.to_i }
      valid = code.all? { |peg| peg.between?(1, PEGS) }
      puts "Invalid input. Input each number one at a time and use pegs #1-#{PEGS} only." unless valid
    end
    code
  end

  def computer_set_code
    code = []
    (1..HOLES).each { code << rand(1..PEGS) }
    code
  end

  def computer_guess(last_guess)
    puts "\nGuess \##{@turn}: "
    # bg_digit tracks which peg to find next
    bg_digit = @turn > (PEGS + 1) ? 0 : @turn
    # initial turn 1 guess, 1111
    return Array.new(HOLES) { bg_digit } if @turn == 1

    # track PERFECT/EXISTS to keep that many of that peg in guesses, while finding new pegs
    return computer_guess_prelim(last_guess, bg_digit) if @fg_digits.size < 4

    # Once the 4 code pegs found, work on permutations of those 4.
    computer_guess_perms(last_guess)
  end

  # Initial guesses to find the code pegs
  def computer_guess_prelim(last_guess, bg_digit)
    guess = []
    shift = @key.include?('PERFECT') ? 0 : 1
    keep = find_keep_pegs_size
    return computer_guess_prelim_shift(last_guess, keep, bg_digit) if shift == 1

    keep.times { @fg_digits << (bg_digit - 1) }
    return computer_guess_perms(last_guess) if @fg_digits.size == 4

    guess += @fg_digits
    (HOLES - guess.size).times { guess << bg_digit }
    guess
  end

  def computer_guess_prelim_shift(last_guess, keep, bg_digit)
    guess = []
    keep.times { @fg_digits.unshift(bg_digit - 1) }
    return computer_guess_perms(last_guess) if @fg_digits.size == 4

    guess << bg_digit
    guess += @fg_digits
    (HOLES - guess.size).times { guess << bg_digit } unless bg_digit.zero?
    guess
  end

  def find_keep_pegs_size
    (@key.size - @key.count('-')) - @fg_digits.size
  end

  def computer_guess_perms(last_guess)
    # Create a list of permutations of the 4 pegs confirmed to be in the code.
    create_perms(last_guess) if @perms.empty?
    all_wrong = @key.all? { |peg| peg == 'EXISTS' }
    # If last guess had all EXISTS, we can delete permutations with those pegs in those holes.
    all_wrong && (1..HOLES).each { |x| @perms.delete_if { |perm| perm[x - 1] == last_guess[x - 1] } }
    # Choose a random permutation. Delete it from the list before returning.
    guess = @perms.sample
    @perms.delete(guess)
    guess
  end

  def create_perms(last_guess)
    @perms = @fg_digits.permutation(HOLES).to_a
    @perms.delete(last_guess)
    p @perms.include?(last_guess)
  end

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

  def valid_guess?(guess)
    guess.size == HOLES && guess.all? { |num| num.is_a?(Integer) && num >= 1 && num <= PEGS }
  end

  # Given a guess, generates the key indicating how good the guess was.
  def generate_guess_key(guess)
    @key = []
    # New 2D array for remaining code/guesses, remainders[0]->remainders[CODE] and remainders[1]->remainders[GUESS]
    remainders = check_perfect_guesses(guess)
    return if remainders[GUESS].size.zero?

    check_partial_guesses(remainders)
    add_misses_to_key
  end

  # Given a guess, updates the key with any PERFECTs, returns a 2D array of remaining guesses/code that are not perfect.
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
      next unless remainders[CODE].include?(remainders[GUESS][rem_guess - 1])

      @key << 'EXISTS'
      remainders[CODE].delete_at(remainders[CODE].index(remainders[GUESS][rem_guess - 1]))
    end
  end

  # Adds '-' to fill in as "misses" in the key
  def add_misses_to_key
    misses = HOLES - @key.size
    misses.times { @key << '-' }
  end

  def display_guess_message(guess)
    puts "Guess: #{guess.inspect}, Key: #{@key}"
  end

  def display_end_message(win, game_mode)
    puts "\nThe code was #{@code.inspect}!"
    if game_mode.zero? && win
      puts "You win! You cracked the code in #{@turn} turns."
    elsif game_mode.zero?
      puts "You lose. You did not crack the code within #{MAX_TURNS} turns."
    elsif game_mode == 1 && win
      puts "You lose. The computer cracked the code in #{@turn} turns."
    else
      puts "You win! The computer did not crack the code within #{MAX_TURNS} turns."
    end
  end
end

game = Game.new
game.play
