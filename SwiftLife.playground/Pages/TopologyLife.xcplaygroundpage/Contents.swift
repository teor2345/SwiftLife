//: Playground - noun: a place where people can play
// A game of life with different topology options

import Cocoa
import XCPlayground

// How big is the life state?
// It's wise to limit the life state size and number of generations in a playground
// For some reason, they seem to leak memory

// Note: the Xcode timeline view is about 500
// pixels wide, and slightly taller
let lifeStateWidth = 256
let lifeStateHeight = 256
let lifeCellCount = lifeStateWidth * lifeStateHeight

// How many of the initial cells are alive?
let initialAliveProportion = 0.5

// The maximum life generation
let maxGeneration = 10_000

// What do we want to draw for each cell?
let cellSize = CGSize(width: 2.5, height: 2.5)
let aliveColor = NSColor.whiteColor()
let deadColor = NSColor.blackColor()

var renderer = LifeRenderer(cellSize: cellSize, aliveColor: aliveColor, deadColor: deadColor)

// Outside is dead by default
var topology: LifeTopology? = nil

// Flat topologies
// Outside is deliberately dead
topology = LifeTopology(flatOutsideAliveProportion: 0.0)
// Outside is alive
topology = LifeTopology(flatOutsideAliveProportion: 1.0)
// Outside is different every time you look
// The "quantum foam" model
topology = LifeTopology(flatOutsideAliveProportion: 0.5)
// Outside is different on different sides
// Try to create a virtual fireplace
// Let's initiate a slow burn from the bottom
topology = LifeTopology.Flat(leftSideAliveProportion: 0.0, topSideAliveProportion: 0.0, rightSideAliveProportion: 0.0, bottomSideAliveProportion: 0.45)

var view = LifeView(origin: CGPoint(x: 0.0, y: 0.0), initialAliveProportion: initialAliveProportion, width: lifeStateWidth, height: lifeStateHeight, topology: topology, maxGeneration: maxGeneration, renderer: renderer)

XCPlaygroundPage.currentPage.liveView = view

let waitTime = 0.0

class Wrapper: NSObject {
  // this function can be safely called without an autorelease pool in place
  @objc func updateLoop(view: LifeView) {
    // wrap everything in an autorelease pool
    autoreleasepool {
      // loop while there are still future generations
      while !view.generation.finished {
        // wrap the loop body in an autorelease pool
        autoreleasepool {
          view.periodicUpdate()

          // Skip complex checks if there's no delay
          if waitTime <= 0.0 {
            // continue the loop by returning from the autorelease closure
            return
          }
          // Delay the next update
          // Only do this on a background thread
          // It will block execution on the main thread
          if NSThread.currentThread() != NSThread.mainThread() {
            NSThread.sleepForTimeInterval(waitTime)
          } else {
            print("Ignored attempt to sleepForTimeInterval on main thread.")
          }
        }
      }
      // report the final state
      print(view.generation)

      // clean up the runloop and thread
      if NSRunLoop.currentRunLoop() != NSRunLoop.mainRunLoop() {
        CFRunLoopStop(NSRunLoop.currentRunLoop().getCFRunLoop())
      }
      if NSThread.currentThread() != NSThread.mainThread() {
        NSThread.currentThread().cancel()
      }

      // Avoid an infinite loop in Xcode
      XCPlaygroundPage.currentPage.finishExecution()
    }
  }
}

NSThread.detachNewThreadSelector(#selector(Wrapper.updateLoop), toTarget: Wrapper(), withObject: view)
