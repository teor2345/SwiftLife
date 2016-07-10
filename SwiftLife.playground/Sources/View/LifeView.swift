import Cocoa

public class LifeView: NSView {
  // A view for life states

  public var generation: LifeGeneration
  public let renderer: LifeRenderer

  var cachedBitmap: NSBitmapImageRep?
  var cachedBitmapGeneration: Int?

  // These are only here to give the override initialiser something to work withx
  static let defaultInitialAliveProportion = 0.5
  static let defaultStateWidth = 10
  static let defaultStateHeight = 10
  // Can't initialise a protocol with nil
  // static let defaultTopology: LifeCellValueDelegate = nil
  static let defaultMaxGeneration = 10

  static let defaultRendererCellSize = CGSize(width: 8, height: 8)
  static let defaultAliveColor = NSColor.whiteColor()
  static let defaultDeadColor = NSColor.blackColor()

  override init(frame: NSRect) {
    let lifeState = LifeState(aliveProportion: LifeView.defaultInitialAliveProportion, width: LifeView.defaultStateWidth, height: LifeView.defaultStateHeight, topology: nil)
    generation = LifeGeneration(lifeState: lifeState, maxGeneration: LifeView.defaultMaxGeneration)
    renderer = LifeRenderer(cellSize: LifeView.defaultRendererCellSize, aliveColor: LifeView.defaultAliveColor, deadColor: LifeView.defaultDeadColor)
    super.init(frame: frame)
    canDrawConcurrently = true
  }

  public init(origin: CGPoint, lifeGeneration: LifeGeneration, renderer rend: LifeRenderer) {
    let frame = NSRect(origin: origin, size: rend.renderSize(lifeGeneration.currentState))
    generation = lifeGeneration
    renderer = rend
    super.init(frame: frame)
    canDrawConcurrently = true
  }

  public convenience init(origin: CGPoint, lifeState: LifeState, maxGeneration: Int, renderer rend: LifeRenderer) {
    let lifeGeneration = LifeGeneration(lifeState: lifeState, maxGeneration: maxGeneration)
    self.init(origin: origin, lifeGeneration: lifeGeneration, renderer: rend)
  }

  public convenience init(origin: CGPoint, initialAliveProportion: Double, width: Int, height: Int, topology: LifeCellValueDelegate?, maxGeneration: Int, renderer rend: LifeRenderer) {
    let lifeGeneration = LifeGeneration(initialAliveProportion: initialAliveProportion, width: width, height: height, topology: topology, maxGeneration: maxGeneration)
    self.init(origin: origin, lifeGeneration: lifeGeneration, renderer: rend)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // We often get asked to paint the same generation twice or three times
  // So cache a bitmap, then redraw it
  override public func drawRect(dirtyRect: NSRect) {
    /*
    // locking focus doesn't seem to be necessary, but it also doesn't seem to degrade performance
    if lockFocusIfCanDraw() {
      // cache a bitmap of the current generation
      if ( cachedBitmap == nil
        || cachedBitmapGeneration != generation.currentGeneration) {
    */

    // draw the view
    renderer.drawLifeState(generation.currentState, dirtyRect: dirtyRect, renderView: self)

    /* Disable bitmap caching - it causes errors
     * we should probably use bitmapImageRepForCachingDisplayInRect: and cacheDisplayInRect:toBitmapImageRep: anyway
        // cache the bitmap
        // sometimes, the code crashes here with a memory copy error, and I'm not sure why
        // at other times, this bitmap gets overreleased during its own deallocation
        cachedBitmap = NSBitmapImageRep(focusedViewRect: self.bounds)
        // store the generation
        cachedBitmapGeneration = generation.currentGeneration
      } else {
        // here's one we prepared earlier
        cachedBitmap!.drawInRect(self.bounds)
      }
      unlockFocus()
    }
    */
  }

  // Yes, we draw over the entire view
  override public var opaque: Bool { return true }

  // we can't pass self.bounds as an AnyObject?
  // so we call this wrapper instead
  public func setNeedsDisplayInBounds() {
    setNeedsDisplayInRect(self.bounds)
  }

  // We log 1 in generationLogRate generations
  static public var generationLogRate = 100

  // This is safe to call from a non-main thread
  // But you must put an autorelease pool in place (timers/run loops do this automatically)
  public func periodicUpdate() {
    let updated = generation.updateLifeState()

    if updated {

      if ( LifeView.generationLogRate >= 0
        && generation.currentGeneration % LifeView.generationLogRate == 0) {
        Swift.print("Generation: \(generation.currentGeneration)")
      }

      /* This interacts poorly with the cached bitmap
       * And it's outdated, before a refactor
      var modifiedRect = NSRect()
      for y in 0..<generation.currentState.height {
        for x in 0..<generation.currentState.width  {
          let cellPosition = CGPoint(x: CGFloat(x) * cellSize.width, y: CGFloat(y) * cellSize.height)
          let cellRect = NSRect(origin: cellPosition, size: cellSize)
          modifiedRect = NSUnionRect(modifiedRect, cellRect)
        }
      }
       */

      // If we're not on the main thread, and we're running in a tight loop,
      // calling setNeedsDisplayInRect doesn't work
      // It does work if we're called from a timer on a non-main thread,
      // likely because there's an associated, running, run loop.
      // But it's hard to tell, so always run this on the main thread
      if NSThread.currentThread() != NSThread.mainThread() {
        performSelectorOnMainThread(#selector(self.setNeedsDisplayInBounds), withObject: nil, waitUntilDone: false)
      } else {
        setNeedsDisplayInBounds()
      }
    }
    /* This outdated code doesn't apply to non-timer views
     if !updated && timer != nil {
       timer.invalidate()
     }
     */
  }
}
