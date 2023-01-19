# mastermind
A command line Mastermind game built in Ruby.

This project was done as part of [The Odin Project](https://www.theodinproject.com/lessons/ruby-mastermind), focusing on Object-Oriented Programming in Ruby.

## Instructions
To play, clone the repository and run:
`ruby ./game.rb`

Otherwise, try the [live demo](https://replit.com/@nathancabigao/mastermind#game.rb).

## Computer Player Algorithm
CPU Algorithm loosely based on a [Puzzling StackExchange thread](https://puzzling.stackexchange.com/a/549). The computer player algorithm proved to be a difficult task to manage, but this computer aims to have a starting strategy of finding out which pegs are contained in the code, and guesses based on possible permutations of those 4 pegs. While it does not always find the correct code in 12 turns, it looks to find it by scrapping unneeded permutations whenever all 4 pegs are in the wrong spot, which makes finding the code easier.