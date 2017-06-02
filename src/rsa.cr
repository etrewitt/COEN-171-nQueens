#!/usr/bin/env crystal

# RSA algorithm

require "primes"

# require "crystalg"
#
# include Crystalg::NumberTheory

def generate_prime : BigInt
  n = 4
  while (n.prime? != true)
    n = Random.rand((10000..10000000))
  end
  return BigInt.new(n)
end

def check_coprimes(n1 : BigInt, n2 : BigInt) : Bool
  # arr1 = n1.factorization
  # arr2 = n2.factorization
  # arr1.each { |elem1|
  #   arr2.each { |elem2|
  #     return false if elem1[0] == elem2[0]
  #   }
  # }
  # return true
  return n1.gcd(n2) == 1
end

def generate_coprime(n : BigInt) : BigInt
  e = n
  while (check_coprimes(e, n) != true)
    e = BigInt.new(Random.rand((10..100 - 1)))
  end
  return e
end

def mod_inv(a : BigInt, m : BigInt) : BigInt
  arr = extgcd(a, m)
  x = arr[1]
  while x < 0
    x += m
  end
  return BigInt.new(x)
end

# Stolen from the crystalg shard (by TobiasGSmollett), which I can't
# get the crystal plugin manager to accept.
def extgcd(a, b)
  x, y, u, v = 0, 1, 1, 0
  while a != 0
    q = b / a
    x, u = u, x - q * u
    y, v = v, y - q * v
    a, b = b - q * a, a
  end
  {b, x, y}
end

def encrypt(n, e, message) : String
end

key_a = generate_prime
key_b = generate_prime
n = key_a * key_b # n
totient = (key_a - 1) * (key_b - 1)

totient_factors = totient.factorization

puts(key_a, key_b)
puts(totient)
puts(totient_factors)
pub_key_exp = generate_coprime(totient) # e
puts(pub_key_exp)
puts(pub_key_exp.factorization)

priv_key_exp = mod_inv(BigInt.new(17), BigInt.new(3120))

# s = "hello, world"
# senc = [] of Int64
# s.each_char { |c|
#   senc << ((c.ord ** pub_key_exp.to_i64) % n).to_i64
# }
# puts senc
#
# sdec = [] of Int64
# senc.each { |c|
#   sdec << ((c ** priv_key_exp.to_i64) % n).to_i64
# }
# puts sdec

# senc = Crypto::Blowfish.encrypt_pair(s, )

puts pub_key_exp.to_i64, n

enc = ((4 ** pub_key_exp.to_i64) % n)
puts enc
dec = ((enc ** priv_key_exp.to_i64) % n)
puts dec

enc = 123 ** 17 % 3233
