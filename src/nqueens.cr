#!/usr/bin/env crystal

# A chessboard will be represented by an n-element array of ints,
# with each element representing a position on a chessboard:
# the index as the column, and the value as the row.

# If *queens* represents a valid solution to the n-queens problem, return true.
# *queens* should be an array of n integers representing a board state.
def check(queens : Array(Int32)) : Bool
  queens.each_with_index { |queen, i|
    # for each queen, check the diagonals if they conflict with another queen
    # down-left diagonal
    x = queen + 1
    y = i + 1
    while x < queens.size && y < queens.size
      if x == queens[y]
        return false
      end
      x += 1
      y += 1
    end
    # down-right diagonal
    x = queen + 1
    y = i - 1
    while x <= queens.size && y >= 0
      if x == queens[y]
        return false
      end
      x += 1
      y -= 1
    end
  }
  return true
  # do not have to check for the up-right or up-left diagonal because a queen higher up
  # will check if there is a queen down the diagonal
end

# Generate a visual representation of a chessboard using unicode symbols.
# NOTE: The type of *queens* is implicitly assumed, as is the return type
# (contrast with `check`). Both ways are acceptable, but this reduces clarity.
def board_string(queens)
  board = ""
  # NOTE: This could be |queen, i| rather than |_, i|, and `queen` rather than
  # `queens[i]`, but I think the readability is better this way?
  queens.each_with_index { |_, i|
    row = ""
    c = ""
    queens.each_with_index { |_, j|
      if queens[i] == j
        c = '♕' # u2655
      elsif (i % 2 - j % 2) == 0
        c = '⬛' # u2b1b
      else
        c = '⬜' # u2b1c
      end
      # NOTE: The above if-elsif-else could be a terser ternary statement?
      # c = queens[i] == j ? '♕' : (i % 2 - j % 2) == 0 ? '⬛' : '⬜'
      row += " " + c
    }
    board += row + "\n"
  }
  return board
end

# Given the set of all *solutions* to an n-queens problem, print them all.
def print_all(solutions : Array(Array(Int32))) : Nil
  printf("Full list of all solutions (%d total):\n", solutions.size)
  digits = Math.log10(solutions.size).ceil.to_u32 # round up
  solutions.each_with_index { |board, i|
    fmtstr = sprintf("[%%0%dd]: %%s\n", digits) # pad appropriately no matter how many digits
    printf(fmtstr, i, board)
  }
  printf("\nExample board layout for %s:\n", solutions[0].to_s)
  puts(board_string(solutions[0]))
end

# Identify all solutions of an n-queens problem, with *n* as an argument.
def find_solutions(n_queens : Int) : Array(Array(Int32))
  solutions = [] of Array(Int32) # empty Array of Int32 Arrays
  queens = (0...n_queens).to_a   # converts a Range of [0, n) to an Array
  # each permutation of queens is stored as `board` (for that iteration)
  queens.each_permutation { |board|
    # if it's a valid solution, append the current board-state to solutions
    solutions << board if check(board) # TODO: finish implementing `check`
  }
  return solutions
end

# No need for a 'main' method.
# May as well have get_input be commandline args.
start = Time.now
# If commandline argument, use that as n's value, otherwise n := 8
n_queens = ARGV.size == 1 ? ARGV[0].to_i : 8 # well. will you look at that, ternary operators exist
solutions = find_solutions(n_queens)
print_all(solutions) # TODO: finish implementing `print_all`
since = Time.now - start
printf("Running time: %.2fms\n", since.total_milliseconds)
