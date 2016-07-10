import Cocoa

public struct LifeRenderer {
  // A renderer for life states

  // What do we want to draw for each cell?
  let cellSize: CGSize
  let aliveColor: NSColor
  let deadColor: NSColor

  public init(cellSize size: CGSize, aliveColor aliveCellColor: NSColor, deadColor deadCellColor: NSColor) {
    cellSize = size
    aliveColor = aliveCellColor
    deadColor = deadCellColor
  }

  public func cellPosition(x x: Int, y: Int) -> CGPoint {
    return CGPoint(x: CGFloat(x) * cellSize.width, y: CGFloat(y) * cellSize.height)
  }

  public func renderSize(stateWidth stateWidth: Int, stateHeight: Int) -> CGSize {
    return CGSize(width: CGFloat(stateWidth) * cellSize.width, height: CGFloat(stateHeight) * cellSize.height)
  }

  public func renderSize(lifeState: LifeState) -> CGSize {
    return renderSize(stateWidth: lifeState.width, stateHeight: lifeState.height)
  }

  public func drawLifeState(lifeState: LifeState, dirtyRect: NSRect, renderView: NSView) {
    deadColor.setFill()
    NSRectFill(dirtyRect)
    aliveColor.setFill()
    for y in 0..<lifeState.height {
      for x in 0..<lifeState.width  {
        // Is it faster to test the rect first, or test whether the cell is alive?

        // Calculate and test the rect
        let cellRect = NSRect(origin: cellPosition(x: x, y: y), size: cellSize)
        if !renderView.needsToDrawRect(cellRect) {
          continue
        }

        // Test the cell
        if !lifeState.isCellAlive(x: x, y: y) {
          continue
        }

        // Fill the rect if it needs to be drawn and the cell is alive
        NSRectFill(cellRect)
      }
    }
  }
}