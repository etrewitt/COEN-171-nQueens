#!/usr/bin/env crystal

# A chessboard will be represented by an n-element array of ints,
# with each element representing a position on a chessboard:
# the index as the column, and the value as the row.

# If *queens* represents a valid solution to the n-queens problem, return true.
# *queens* should be an array of n integers representing a board state.
def check(queens : Array(Int32)) : Bool
  # FIXME: obviously there should be an actual check here
  if queens.size == 8
    return queens == [0, 4, 7, 5, 2, 6, 1, 3] # This is a known 'correct solution'
  else
    return true
  end
end

# Generate a visual representation of a chessboard using unicode symbols.
# The type of *queens* is implicitly assumed, as is the return type
# (contrast with `check`). Both ways are acceptable, but this adds clarity.
def board_string(queens)
  board = ""
  # TODO: construct a unicode board
  return board
end

# Given the set of all *solutions* to an n-queens problem, print them all.
def print_all(solutions : Array(Array(Int32))) : Nil
  puts(solutions) # NOTE: this is just a test output, and should be removed
  # TODO: print all the things as we want
end

# Identify all solutions of an n-queens problem, with *n* as an argument.
def find_solutions(n_queens : Int) : Array(Array(Int32))
  solutions = [] of Array(Int32) # empty Array of Int32 Arrays
  queens = (0...n_queens).to_a   # converts a Range of [0, n) to an Array
  # each permutation of queens is stored as `board` (for that iteration)
  queens.each_permutation { |board|
    # if it's a valid solution, append the current board-state to solutions
    solutions << board if check(board) # TODO: finish implementing
  }
  return solutions
end

# No need for a 'main' method.
# May as well have get_input be commandline args.
start = Time.now
# If commandline argument, use that as n's value, otherwise n := 8
n_queens = ARGV.size == 1 ? ARGV[0].to_i : 8 # well. will you look at that, ternary operators exist
solutions = find_solutions(n_queens)
print_all(solutions) # TODO: finish implementing
since = Time.now - start
printf("Running time: %.2fms\n", since.total_milliseconds)
