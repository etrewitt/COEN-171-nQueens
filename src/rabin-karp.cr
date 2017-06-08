#!/usr/bin/env crystal

NPATTERNS = 2 ** 10
STRLEN    = 2 ** 10

class RollingHash
  @pos = 0
  @base : Int32

  def initialize(@text : String, @size : Int32)
    @hash = 0
    @base = (2 ** size) - 1

    @mod = 11383 # to prevent overflow; prime

    (0...size).each { |i|
      @hash *= @base
      @hash += @text[i].ord
      @hash %= @mod
    }
  end

  def next : Int32
    @hash = ((@hash - @text[@pos].ord) * @base + @text[@pos + @size].ord) % @mod
    @pos += 1
    return @hash
  end

  def onetime(s) : Int32
    hash = 0
    s.each_char { |c|
      hash *= @base
      hash += c.ord
      hash %= @mod
    }
    return hash
  end
end

def rabin_karp(doc : String, patterns : Array(String))
  maxlen = patterns.max_by { |s| s.size }.size
  print "max: ", maxlen, '\n'
  hashes = Hash(String, Array(Int32)).new
  patterns.each { |pattern|
    hashes[pattern] = [] of Int32
  }
  (0...doc.size - maxlen).each { |i|
    hash = doc[i, maxlen]
    return i, hash if hashes[hash]? != nil
  }
  return hashes
end

def rabin_karp2(doc : String, patterns : Array(String)) : Hash(Int32, Array(Int32))
  maxlen = patterns.max_by { |s| s.size }.size
  hashes = Hash(Int32, Array(Int32)).new

  hasher = RollingHash.new(doc, maxlen)

  patterns.each { |pattern|
    h = hasher.onetime(pattern)
    hashes[h] = [] of Int32
  }
  (0...doc.size - maxlen).each { |i|
    h = hasher.next
    hashes[h] << i if hashes[h]? != nil
  }
  return hashes
end

def rabin_karp3(doc : String, patterns : Array(String))
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

def brute_search(doc : String, patterns : Array(String))
  patterns.each { |pattern|
    i = doc.index(pattern)
    return i, pattern if i
  }
  return nil, ""
end

def generate_patterns(n_patterns : Int32, strlen : Int32, doc : String) : Array(String)
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

doc = File.read("text.txt")
ps = generate_patterns(NPATTERNS, STRLEN, doc)

printf "Generated %d patterns of %d chars in %.2fms\n", ps.size, STRLEN, (Time.now - start).total_milliseconds

puts "Algorithm started"
algstart = Time.now

brute_start = Time.now
i, s = brute_search(doc, ps)
if i
  printf "Brute force search found string %s[...]%s at index %d\n",
    s[0, 10], s[s.size - 10, s.size], i
else
  puts "Brute: No pattern found"
end
printf("Brute iteration running time: %.2fms\n\n", (Time.now - brute_start).total_milliseconds)

rk_start = Time.now
i, s = rabin_karp3(doc, ps)
if i
  printf "Rabin-Karp search found string %s[...]%s at index %d\n",
    s[0, 10], s[s.size - 10, s.size], i
else
  puts "RK: No pattern found"
end
printf("Rabin-Karp running time: %.2fms\n", (Time.now - rk_start).total_milliseconds)

since = Time.now - start
printf("Total elapsed time: %.2fms\n", since.total_milliseconds)
