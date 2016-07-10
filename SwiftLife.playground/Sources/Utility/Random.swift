import Foundation

// A set of utility functions for producing random numbers

// Return a random integer between 0 and (2**32 - 1)
public func randomUInt32() -> UInt32 {
  return arc4random()
}

// Return a random integer between 0 and (2**64 - 1)
public func randomUInt64() -> UInt64 {
  return (UInt64(randomUInt32()) << 32) | UInt64(randomUInt32())
}

// Return a random float between 0.0 and 1.0 (inclusive)
// The random input of 32 bits exceeds the expected Double precision of 24 bits
// The conversion to Float aims to preserve this entropy, subject to rounding
public func randomFloat() -> Float {
  // The input is a random unsigned 32-bit integer with 2**32 possible values
  // These values are between 0 and (2**32 - 1), and are divided by (2**32 - 1)
  // Given that doubles have 24 bits of precision, the 32 bit input should ensure we
  // cover the full range
  return Float(randomUInt32()) / Float(UInt32.max)
}

// Return a random double between 0.0 and 1.0 (inclusive)
// The random input of 64 bits exceeds the expected Double precision of 53 bits
// The conversion to Double aims to preserve this entropy, subject to rounding
public func randomDouble() -> Double {
  // The input is a random unsigned 64-bit integer with 2**64 possible values
  // These values are between 0 and (2**64 - 1), and are divided by (2**64 - 1)
  // Given that doubles have 53 bits of precision, the 64 bit input should ensure we
  // cover the full range
  return Double(randomUInt64()) / Double(UInt64.max)
}

// Return a random Bool, which is true with trueProbability
public func randomBool(trueProbability: Float) -> Bool {
  // If trueProbability is 0.0, all should be false
  // If it's 1.0, all should be true
  // So neither < nor <= is the correct comparison below, although the chance of an incorrect result is minimal, at somewhere between 1/1**24 and 1/1**32
  if trueProbability >= 1.0 {
    return true
  } else if trueProbability <= 0.0 {
    return false
  }

  // randomFloat is between 0.0 and 1.0 inclusive
  let randFloat = randomFloat()
  // The difference between < and <= here is irrelevant, given the excess precision
  if randFloat <= trueProbability {
    return true
  } else {
    return false
  }
}

// Return a random Bool, which is true with trueProbability
public func randomBool(trueProbability: Double) -> Bool {
  // If trueProbability is 0.0, all should be false
  // If it's 1.0, all should be true
  // So neither < nor <= is the correct comparison below, although the chance of an incorrect result is minimal, at somewhere between 1/1**53 and 1/1**64
  if trueProbability >= 1.0 {
    return true
  } else if trueProbability <= 0.0 {
    return false
  }

  // randomDouble is between 0.0 and 1.0 inclusive
  let randDouble = randomDouble()
  // The difference between < and <= here is irrelevant, given the excess precision
  if randDouble <= trueProbability {
    return true
  } else {
    return false
  }
}