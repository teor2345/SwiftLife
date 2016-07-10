import Foundation

public enum LifeTopology: LifeCellValueDelegate {
  // Some possible topologies and implementation variants of a game of life surface

  // A flat game of life is a bounded surface, with cells outside the boundary taking a particular value
  // Typically, a flat game of life assumes cells outside are dead, which is equivalent to outsideAliveProportion: 0.0.
  // But we allow dead, alive, or a random value each time an outside cell is read
  // This may produce inconsistent results, because random cell values aren't saved between inside cells or updates
  // https://en.wikipedia.org/wiki/Surface_%28topology%29#Closed_surfaces
  case Flat(leftSideAliveProportion: Double, topSideAliveProportion: Double, rightSideAliveProportion: Double, bottomSideAliveProportion: Double)

  public enum SphereVariant {
    // One implementation of a sphere joins adjacent sides
    // The implementation is different depending on whether we join side 0 to side 1 (clockwise), or side 0 to side 3 (anticlockwise)
    case JoinSides(clockwise: Bool)
    // Another implementation of a sphere joins adjacent half-sides
    // The implementation is different depending on whether we join each half-side to the other half of the same side (clockwise), or to the other half of the adjacent side (anticlockwise)
    case JoinHalfSides(clockwise: Bool)
  }

  // The surface of a sphere, a closed surface
  // https://en.wikipedia.org/wiki/Sphere
  case Sphere(variant: SphereVariant)

  // The surface of a one-hole torus, a closed surface that joins opposite sides in parallel orientations
  // (the top of one side joins to the top of the other)
  // There seems to be no easy way to implement the n-hole torus variants
  // https://en.wikipedia.org/wiki/Torus
  case Torus

  // The surface of a projective plane, a closed surface that joins opposite sides in reversed orientations
  // (the top of one side joins to the bottom of the other)
  // https://en.wikipedia.org/wiki/Real_projective_plane
  case ProjectivePlane

  // The surface of a klein bottle, a closed surface that joins one pair of opposite sides in a parallel orientation, and the other pair in a reverse orientation
  // The implementation is different depending on whether the X or Y coordinates are reversed when joined
  // There seems to be no easy way to implement the n-hole klein bottle variants
  // https://en.wikipedia.org/wiki/Klein_bottle
  case KleinBottle(reverseX: Bool)

  // There are likely many more topolgies and variants, but this seems sufficient for now

  // Use a Torus as the default
  public init() {
    self = Torus
  }

  // Initialise a Flat using one Double rather than four
  public init(flatOutsideAliveProportion: Double) {
    self = Flat(leftSideAliveProportion: flatOutsideAliveProportion, topSideAliveProportion: flatOutsideAliveProportion, rightSideAliveProportion: flatOutsideAliveProportion, bottomSideAliveProportion: flatOutsideAliveProportion)
  }

  // Initialise a sphere using two booleans rather than the nested enum
  public init(sphereJoinSides: Bool, clockwise: Bool) {
    let sphereVariant = sphereJoinSides ? SphereVariant.JoinSides(clockwise: clockwise) : SphereVariant.JoinHalfSides(clockwise: clockwise)
    self = Sphere(variant: sphereVariant)
  }

  // The sides of a rectangle
  public enum Side {
    case Left
    case Top
    case Right
    case Bottom
  }

  // Returns the nearest side to (x, y) in a rectangle of (width, height)
  // Cells on the diagonals are assigned a consistent but arbitrary side
  // Works for cells inside and outside (0..<width, 0..<height)
  public static func nearestSide(width width: Int, height: Int, x: Int, y: Int) -> Side {
    // Cocoa uses a cartesian coordinate system - 0,0 is bottom left
    if x < y {
      // we're above the x == y diagonal
      // top or left
      if x < height - y {
        // we're below the x = -y diagonal
        return Side.Left
      } else {
        return Side.Top
      }
    } else {
      // bottom or right
      if x < height - y {
        return Side.Bottom
      } else {
        return Side.Right
      }
    }
  }

  // Is the cell at (x, y) alive?
  // Delegates must handle x and y outside the bounds of 0..<lifeState.width and 0..<lifeState.height
  public func isCellAlive(lifeState: LifeState, x: Int, y: Int) -> Bool {
    // If it's in the state, just return that value
    if lifeState.isCellInState(x: x, y: y) {
      return lifeState.isStorageCellAlive(x: x, y: y)
    }

    // Otherwise, return an alternate value
    switch self {
    // Most of the time, Flat topologies will have dead cells (0.0) outside the boundary
    case let .Flat(leftSideAliveProportion: leftSideAliveProportion, topSideAliveProportion: topSideAliveProportion, rightSideAliveProportion: rightSideAliveProportion, bottomSideAliveProportion: bottomSideAliveProportion):
      switch LifeTopology.nearestSide(width: lifeState.width, height: lifeState.height, x: x, y: y) {
      case Side.Left:
        return randomBool(leftSideAliveProportion)
      case Side.Top:
        return randomBool(topSideAliveProportion)
      case Side.Right:
        return randomBool(rightSideAliveProportion)
      case Side.Bottom:
        return randomBool(bottomSideAliveProportion)
      }
    case let .Sphere(variant: sphereVariant):
      // topologically, these are equivalent
      // it's all about how you slice the sphere
      switch sphereVariant {
      case let .JoinSides(clockwise: clockwise):
        print("Not Yet Implemented")
        return false
      case let .JoinHalfSides(clockwise: clockwise):
        print("Not Yet Implemented")
        return false
      }
    case .Torus:
      print("Not Yet Implemented")
      return false
    case .ProjectivePlane:
      print("Not Yet Implemented")
      return false
    case let .KleinBottle(reverseX: reverseX):
      print("Not Yet Implemented")
      return false
    }
  }
}