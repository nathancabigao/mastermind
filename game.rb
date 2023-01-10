# frozen-string-literal: true

# Constants
MAX_TURNS = 12
HOLES = 4
PEGS = 6

# Create and play games of Mastermind
class Game
  def initialize
    @turn = 0
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

  # Core gameplay loop
  def play
    welcome
  end
end

game = Game.new
game.play
