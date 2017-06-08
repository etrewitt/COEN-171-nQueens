# Print out all indices and elements of *arr*, return size of *arr*.
def foo(arr)
  arr.each_with_index { |e, i|
    print i, ": ", e, '\n'
  }
  arr.size
end

# Overload `foo` with zero arguments; returns a tuple of Int32s.
def foo : {Int32, Int32}
  return 4, 2
end

# Arrays can have multiple types of elements
foo(["Hello", "COEN", 171, "class"])
puts typeof(["Hello", "COEN", 171, "class"])

# Append three ranges into an array
chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a

puts chars

s = chars.sample(10)
puts s

ps = [] of String

(0...32).each {
  s = ""
  chars.sample(2 ** 6).each { |c|
    s += c
  }
  ps << s
}

doc = File.read("rabin-karp/text.txt")
str_len = 1024
rng = Random.new
i = rng.rand(doc.size - str_len)
s = doc[i, i + str_len]

print "found at ", doc.index(s), "\n"

puts foo
