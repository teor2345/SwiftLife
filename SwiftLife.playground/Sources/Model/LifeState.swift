import Foundation

public protocol LifeCellValueDelegate {
  // A protocol for retrieving cell values from a delegate
  // Used to implement topologies, many of which locate cell values outside the state from elsewhere in the state

  // Delegates could store a (weak) reference to the lifeState
  // Instead, we get it passed in every time

  // Is the cell at (x, y) alive?
  // Delegates must handle x and y outside the bounds of 0..<lifeState.width and 0..<lifeState.height
  func isCellAlive(lifeState: LifeState, x: Int, y: Int) -> Bool

  /* Allowing cells outside the storage to be set seems confusing and error-prone
  // Set the cell at (x, y) to alive or dead based on cellAliveValue
  func setCellAlive(inout lifeState: LifeState, cellIsAliveValue: Bool, x: Int, y: Int)
 */
}

public struct LifeState {
  // The state of a Game of Life

  public typealias CellType = Bool
  public typealias StorageRowType = [CellType]
  public typealias StorageType = [StorageRowType]

  public let width: Int
  public let height: Int
  public var cellCount: Int { return width * height }
  
  // cellState is in column-major order (the outer array is height / y)
  var cellState: StorageType

  public var topology: LifeCellValueDelegate?

  init(width w: Int, height h: Int, cellState c: StorageType, topology t: LifeCellValueDelegate?) {
    assert(c.count == h)
    assert(c.count == 0 || c[0].count == w)
    width = w
    height = h
    cellState = c
    topology = t
  }

  public init(life: LifeState) {
   self.init(width: life.width, height: life.height, cellState: life.cellState, topology: life.topology)
  }

  // Initialise life state where all cells are alive or dead
  public init(repeatedAliveValue: Bool, width: Int, height: Int, topology: LifeCellValueDelegate?) {
    let row = Array(count: width, repeatedValue: repeatedAliveValue)
    let lifeState = Array(count: height, repeatedValue: row)
    self.init(width: width, height: height, cellState: lifeState, topology: topology)
  }

  // Initialise a life state where aliveProportion of cells are alive
  // Proportions greater than or equal to 1.0 mean "all alive"
  // Proportions less than or equal to 0.0 mean "all dead"
  public init(aliveProportion: Double, width: Int, height: Int, topology: LifeCellValueDelegate?) {

    var randomLifeState: StorageType = Array()

    for _ in 0..<height {
      var randomRow: StorageRowType = Array()
      for _ in 0..<width {
        // We don't need Double precision here, and it wastes time on an additonal RNG call
        if randomBool(Float(aliveProportion)) {
          randomRow.append(true)
        } else {
          randomRow.append(false)
        }
      }
      randomLifeState.append(randomRow)
    }

    self.init(width: width, height: height, cellState: randomLifeState, topology: topology)
  }

  // Is (x, y) within (0..<width, 0..<height)?
  public func isCellInState(x x: Int, y: Int) -> Bool {
    return x >= 0 && x < width
        && y >= 0 && y < height
  }

  // Ask the delegate if the cell at (x, y) is alive
  // If there is no delegate, returns false for cells that don't exist
  public func isCellAlive(x x: Int, y: Int) -> Bool {
    guard let validTopology = topology else {
      if isCellInState(x: x, y: y) {
        return isStorageCellAlive(x: x, y: y)
      } else {
        return false
      }
    }

    return validTopology.isCellAlive(self, x: x, y: y)
  }

  // /* Allowing cells outside the storage to be set seems confusing and error-prone */
  // /* Ask the delegate to */ set the cell at (x, y) to alive or dead based on cellAliveValue
  // /* If there is no delegate, */ ignores and warns on attempts to set cells that don't exist
  public mutating func setCellAlive(cellIsAliveValue: Bool, x: Int, y: Int) {
    /* guard let validTopology = topology else { */

    if isCellInState(x: x, y: y) {
      setStorageCellAlive(cellIsAliveValue, x: x, y: y)
    } else {
      print("Attempted to set out of bounds cell at (\(x),\(y)) to \(cellIsAliveValue), width \(width), height \(height)")
    }

    /*  return
    }

    validTopology.setCellAlive(&self, cellIsAliveValue: cellIsAliveValue, x: x, y: y) */
  }

  // Is the cell at (x, y) alive in our internal cell storage?
  // Should only be called by delegates, or as a fallback in this class
  // Preconditions: x < lifeWidth, y < lifeHeight
  public func isStorageCellAlive(x x: Int, y: Int) -> Bool {
    return cellState[y][x]
  }

  // Set the cell at (x, y) to alive or dead in our internal cell storage based on cellAliveValue
  // Should only be called /* by delegates, or */ as a fallback in this class
  // Preconditions: x < lifeWidth, y < lifeHeight
  public mutating func setStorageCellAlive(cellIsAliveValue: Bool, x: Int, y: Int) {
    cellState[y][x] = cellIsAliveValue
  }

  /* Calculate and return the number of alive neighbours of (x, y) in state
   * Every cell interacts with its eight neighbours, which are the cells that are horizontally, vertically, or diagonally adjacent.
   * https://en.wikipedia.org/wiki/Conway's_Game_of_Life
   */
  public func getAliveNeighbourCount(x x: Int, y: Int) -> Int {
    var aliveNeighbourCount = 0
    for j in (y-1)...(y+1) {
      for i in (x-1)...(x+1) {
        // Don't count this cell
        if i == x && j == y {
          continue;
        }
        // Count all the other cells
        if isCellAlive(x: i, y: j) {
          aliveNeighbourCount += 1
        }
      }
    }
    return aliveNeighbourCount
  }

  /*: Calculate and return the next state from state
   ### The Conway's Game of Life rules are:
   * Every cell interacts with its eight neighbours, which are the cells that are horizontally, vertically, or diagonally adjacent.
   * Any live cell with fewer than two live neighbours dies, as if caused by under-population.
   * Any live cell with two or three live neighbours lives on to the next generation.
   * Any live cell with more than three live neighbours dies, as if by over-population.
   * Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
   See https://en.wikipedia.org/wiki/Conway's_Game_of_Life
   If any cells were modified, return true
   
   This is safe to call from a non-main thread
   But you must put an autorelease pool in place (timers/run loops do this automatically)
   */
  public func getNextLifeState() -> (LifeState, Bool)  {
    // Make all the cells a clone of the existing state
    var newState = self
    // Track modified cells
    var modified = false
    for y in 0..<height {
      for x in 0..<width  {
        // we want to count the alive neighbours in *our* state, not the new one
        let aliveNeighbourCount = getAliveNeighbourCount(x: x, y: y)
        // we want to check if the cell is alive in *our* state, not the new one
        if isCellAlive(x: x, y: y) {
          // We skip rules that leave the cell to the same state it's already in

          if aliveNeighbourCount < 2 {
            // Any live cell with fewer than two live neighbours dies, as if caused by under-population.
            // we want to change the cell in the *new* state, not our state
            newState.setCellAlive(false, x: x, y: y)
            modified = true
          } else if aliveNeighbourCount > 3 {
            // Any live cell with more than three live neighbours dies, as if by over-population.
            // we want to change the cell in the *new* state, not our state
            newState.setCellAlive(false, x: x, y: y)
            modified = true
          }
        } else /* if it's dead */ {
          if aliveNeighbourCount == 3 {
            // Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
            // we want to change the cell in the *new* state, not our state
            newState.setCellAlive(true, x: x, y: y)
            modified = true
          }
        }
      }
    }
    return (newState, modified)
  }
}

extension LifeState: CustomStringConvertible {
  /// A type with a customized textual representation.

  /// A textual representation of `self`.
  // Print out the life state in a text grid
  public var description: String {
    var lifeStateString = ""
    for lifeStateRow in cellState {
      // add a newline between each row, but not at the end
      if !lifeStateString.isEmpty {
        lifeStateString += "\n"
      }
      for lifeStateCell in lifeStateRow {
        if lifeStateCell {
          lifeStateString += "*"
        } else {
          lifeStateString += " "
        }
      }
    }
    return lifeStateString
  }
}
