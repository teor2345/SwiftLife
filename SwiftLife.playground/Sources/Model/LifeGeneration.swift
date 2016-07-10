import Foundation

public struct LifeGeneration {
  // A generator for a sequence of life states

  public var currentState: LifeState
  public var stateIsUnchanging = false

  // The maximum and current life generation
  public let maxGeneration: Int
  public var currentGeneration = 0
  public var reachedMaximumGeneration: Bool { return currentGeneration >= maxGeneration }

  public var finished: Bool { return stateIsUnchanging || reachedMaximumGeneration }

  public init(lifeState life: LifeState, maxGeneration maxGen: Int) {
    currentState = life
    maxGeneration = maxGen
  }

  public init(initialAliveProportion: Double, width: Int, height: Int, topology: LifeCellValueDelegate?, maxGeneration: Int) {
    self.init(lifeState: LifeState(aliveProportion: initialAliveProportion, width: width, height: height, topology: topology), maxGeneration: maxGeneration)
  }

  // if the life state was updated, returns true
  // This is safe to call from a non-main thread
  // But you must put an autorelease pool in place (timers/run loops do this automatically)
  public mutating func updateLifeState() -> Bool {
    if currentGeneration < maxGeneration {
      let modified: Bool
      (currentState, modified) = currentState.getNextLifeState()
      currentGeneration += 1

      if !modified {
        stateIsUnchanging = true
      }

      return modified
    }
    return false
  }
}

extension LifeGeneration: CustomStringConvertible {
  /// A type with a customized textual representation.

  /// A textual representation of `self`.
  // Print out the life generation, the life state, and a footer
  public var description: String {
    var lifeGenString = ""

    lifeGenString += "Generation: \(currentGeneration)\n"

    if stateIsUnchanging {
      lifeGenString += "All subsequent generations will be identical\n"
    } else {
      lifeGenString += currentState.description + "\n"
    }
    
    if currentGeneration >= maxGeneration {
      lifeGenString += "Reached maximum generation \(maxGeneration)\n"
    }

    lifeGenString += String(count: currentState.width, repeatedValue: Character("-"))

    return lifeGenString
  }
}