//: Playground - noun: a place where people can play
// A text-based Game of Life

import Foundation
import XCPlayground

// How big is the life state?// How big is the life state?
// It's wise to limit the life state size and number of generations in a playground
// For some reason, they seem to leak memory

// Note: the Xcode debug output is about 150 characters wide
let lifeStateWidth = 150
let lifeStateHeight = 30
let lifeCellCount = lifeStateWidth * lifeStateHeight

// How many of the initial cells are alive?
let initialAliveProportion = 0.5

// The maximum life generation
let maxGeneration = 1_000

// A life state generator
var lifeGen = LifeGeneration(initialAliveProportion: initialAliveProportion, width: lifeStateWidth, height: lifeStateHeight, topology: nil, maxGeneration: maxGeneration)

// return false if no more updates are needed
public func periodicUpdate() -> Bool {
  let updated = lifeGen.updateLifeState()

  print(lifeGen.description)

  return updated
}

print(lifeGen.description)
while true {
  if !periodicUpdate() {
    break
  }
}
