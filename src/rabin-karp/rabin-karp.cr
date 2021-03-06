#!/usr/bin/env crystal

NPATTERNS = 2 ** 10
STRLEN    = 2 ** 10

# Rolling hash generator for use with algorithms such as Rabin-Karp.
# Initialized with the entire text to generate a rolling hash for, and can then
# be called upon to return the next hash in the sequence with `#next`.
# Hashes are all Int32s.
class RollingHash
  @pos = 0
  @base : Int32

  # Creates a new RollingHash for the document *text*, for substrings
  # of length *size*.
  def initialize(@text : String, @size : Int32)
    @hash = 0
    @base = (2 ** size) - 1

    @mod = 11383 # to prevent overflow; this is an arbitrary prime number

    # Initializes the hash to the first *size*-character substring.
    (0...size).each { |i|
      @hash *= @base
      @hash += @text[i].ord
      @hash %= @mod
    }
  end

  # Advances the substring window by one and returns the next hash.
  def next : Int32
    @hash = ((@hash - @text[@pos].ord) * @base + @text[@pos + @size].ord) % @mod
    @pos += 1
    return @hash
  end

  # Returns a hash for a single string from this instance's exiting parameters.
  # Doesn't store the string as it will never be advanced.
  def onetime(s : String) : Int32
    hash = 0
    s.each_char { |c|
      hash *= @base
      hash += c.ord
      hash %= @mod
    }
    return hash
  end
end

# Uses the Rabin-Karp algorithm to search *doc* for any pattern in *patterns*.
# All strings in *patterns* should be the same length.
# Much more time-efficient than `#search_brute_force` for large numbers of patterns.
# Returns the index and matched pattern if found, else nil.
def search_rabin_karp(doc : String, patterns : Array(String)) : {Int32 | Nil, String}
  maxlen = patterns.max_by { |s| s.size }.size
  hashes = Set(Int32).new(initial_capacity = patterns.size)

  hasher = RollingHash.new(doc, maxlen)

  patterns.each { |pattern|
    h = hasher.onetime(pattern)
    hashes << h
  }
  (0...doc.size - maxlen).each { |i|
    h = hasher.next
    return i, doc[i, i + maxlen] if hashes.includes?(h)
  }
  return nil, ""
end

# For each pattern String in *patterns*, iterate over *doc* until the first is found.
# All strings in *patterns* should be the same length.
# Returns the index and matched pattern if found, else nil.
def search_brute_force(doc : String, patterns : Array(String))
  patterns.each { |pattern|
    i = doc.index(pattern)
    return i, pattern if i
  }
  return nil, ""
end

def hash_search(doc : String, patterns : Array(String))
  maxlen = patterns.max_by { |s| s.size }.size
  hashes = Set(String).new(initial_capacity = patterns.size)

  patterns.each { |pattern|
    hashes << pattern
  }

  (0...doc.size - maxlen).each { |i|
    h = doc[i, maxlen]
    return i, h if hashes.includes?(h)
  }
  return nil, ""
end

# Returns an Array with *n_patterns* *strlen*-character Strings,
# of which one is a substring of *doc* and the rest are random.
def generate_patterns(n_patterns, strlen, doc : String) : Array(String)
  ps = [] of String

  chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a

  (0...n_patterns - 1).each {
    s = ""
    (0...strlen).each {
      s += chars.sample
    }
    ps << s
  }
  rng = Random.new(0)
  i = rng.rand(doc.size - strlen)
  s = doc[i, i + strlen]
  ps.insert(rng.rand(ps.size), s)
  ps
end

start = Time.now

# Command line args
n_patterns = ARGV.size == 2 ? ARGV[0].to_i : NPATTERNS
strlen = ARGV.size == 2 ? ARGV[1].to_i : STRLEN

# Opens and read all the text from text.txt
doc = File.read("text.txt")
ps = generate_patterns(n_patterns, strlen, doc)

printf "Generated %d patterns of %d chars each in %.2fms\n", ps.size, strlen, (Time.now - start).total_milliseconds

puts "Algorithm started\n"
algstart = Time.now

brute_start = Time.now
i, s = search_brute_force(doc, ps)
if i
  printf "Brute force search found string %s[...]%s at index %d\n",
    s[0, 10], s[s.size - 10, s.size], i
else
  puts "Brute: No pattern found"
end
printf "Brute iteration running time: %.2fms\n\n", (Time.now - brute_start).total_milliseconds

rk_start = Time.now
i, s = search_rabin_karp(doc, ps)
if i
  printf "Rabin-Karp search found string %s[...]%s at index %d\n",
    s[0, 10], s[s.size - 10, s.size], i
else
  puts "RK: No pattern found"
end
printf "Rabin-Karp running time: %.2fms\n", (Time.now - rk_start).total_milliseconds

# This is too slow to use for a demonstration. String comparison takes a *very* long time.
# rk_start = Time.now
# i, s = hash_search(doc, ps)
# if i
#   printf "Naive hash search found string %s[...]%s at index %d\n",
#     s[0, 10], s[s.size - 10, s.size], i
# else
#   puts "RK: No pattern found"
# end
# printf("Naive hash running time: %.2fms\n", (Time.now - rk_start).total_milliseconds)

since = Time.now - start
printf "Total elapsed time: %.2fms\n", since.total_milliseconds
