#!/usr/bin/env crystal

# A chessboard will be represented by an n-element array of ints,
# with each element representing a position on a chessboard:
# the index as the row, and the value as the column.
# In our implementation, the upper-left square is (0, 0).

# If *queens* represents a valid solution to the n-queens problem, returns true.
# *queens* should be an array of n integers representing a board state.
def check(queens : Array(Int32)) : Bool
  queens.each_with_index { |queen, i|
    # for each queen, check the diagonals if they conflict with another queen
    # down-left diagonal:
    x = queen + 1
    y = i + 1
    while x < queens.size && y < queens.size
      return false if x == queens[y]
      x += 1; y += 1
    end
    # down-right diagonal:
    x = queen + 1
    y = i - 1
    while x <= queens.size && y >= 0
      return false if x == queens[y]
      x += 1; y -= 1
    end
  }
  return true
  # Do not have to check for the up-right or up-left diagonal, because
  # a queen higher up will check if there is a queen down the diagonal.
end

# Generates a visual representation of a chessboard using unicode symbols.
# NOTE: The type of *queens* is implicitly assumed, as is the return type
# (contrast with `#check`). Both ways are acceptable, but this reduces clarity.
def board_string(queens)
  board = ""
  # NOTE: This could be |queen, i| rather than |_, i|, and `queen` rather than
  # `queens[i]`, but we prefer the readability this way.
  queens.each_with_index { |_, i|
    row = ""
    queens.each_with_index { |_, j|
      if queens[i] == j
        c = '♕' # u2655
      elsif (i % 2 - j % 2) == 0
        c = '⬛' # u2b1b
      else
        c = '⬜' # u2b1c
      end
      # NOTE: The above if-elsif-else could be a terser ternary statement:
      # c = queens[i] == j ? '♕' : (i % 2 - j % 2) == 0 ? '⬛' : '⬜'
      row += " " + c
    }
    board += row + "\n"
  }
  return board
end

# Prints all *solutions* to a given n-queens problem.
def print_all(solutions : Array(Array(Int32))) : Nil
  printf("Full list of all solutions (%d total):\n", solutions.size)
  # pad appropriately no matter how many digits
  digits = Math.log10(solutions.size).ceil.to_u32 # round up
  solutions.each_with_index { |board, i|
    # e.g., for solutions.size == 200, becomes "[%03d]: %s\n", which can then
    # be used as an actual format string with 0-padding to 3 digits.
    fmtstr = sprintf("[%%0%dd]: %%s\n", digits)
    printf(fmtstr, i, board)
  }
  printf("\nExample board layout for %s:\n", solutions[0].to_s)
  puts(board_string(solutions[0]))
end

# Identifies all solutions of an n-queens problem given *n*.
def find_solutions(n_queens : Int) : Array(Array(Int32))
  solutions = [] of Array(Int32) # empty Array of Int32 Arrays
  queens = (0...n_queens).to_a   # converts a Range of [0, n) to an Array
  # each permutation of queens is stored as `board` (for that iteration)
  queens.each_permutation { |board|
    # if it's a valid solution, append the current board-state to solutions
    solutions << board if check(board)
  }
  return solutions
end

# No need for a 'main' method.
start = Time.now
# If commandline argument, use that as n's value, otherwise n := 8
n_queens = ARGV.size == 1 ? ARGV[0].to_i : 8
solutions = find_solutions(n_queens)
if solutions.empty? # check to make sure that solutions exist
  printf("ERROR: No valid solutions for n = %d.\n", n_queens)
else
  print_all(solutions)
end
since = Time.now - start
printf("Running time: %.2fms\n", since.total_milliseconds)
