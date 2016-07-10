//: Playground - noun: a place where people can play
// A threaded Game of Life, using a timer for updates

import Cocoa
import XCPlayground

// How big is the life state?
// It's wise to limit the life state size and number of generations in a playground
// For some reason, they seem to leak memory

// Note: the Xcode timeline view is about 500
// pixels wide, and slightly taller
let lifeStateWidth = 64
let lifeStateHeight = 64
let lifeCellCount = lifeStateWidth * lifeStateHeight

// How many of the initial cells are alive?
let initialAliveProportion = 0.5

// The maximum life generation
let maxGeneration = 100

// What do we want to draw for each cell?
let cellSize = CGSize(width: 8, height: 8)
let aliveColor = NSColor.whiteColor()
let deadColor = NSColor.blackColor()

var renderer = LifeRenderer(cellSize: cellSize, aliveColor: aliveColor, deadColor: deadColor)

var view = LifeView(origin: CGPoint(x: 0.0, y: 0.0), initialAliveProportion: initialAliveProportion, width: lifeStateWidth, height: lifeStateHeight, topology: nil, maxGeneration: maxGeneration, renderer: renderer)

XCPlaygroundPage.currentPage.liveView = view

var updateTimer = NSTimer(timeInterval: 0.1, target: view, selector: #selector(LifeView.periodicUpdate), userInfo: nil, repeats: true)
updateTimer.tolerance = 0.05

class Wrapper: NSObject {
  @objc func addTimerToRunLoop() {
    NSRunLoop.currentRunLoop().addTimer(updateTimer, forMode: NSRunLoopCommonModes)
    NSRunLoop.currentRunLoop().run()
  }
}

NSThread.detachNewThreadSelector(#selector(Wrapper.addTimerToRunLoop), toTarget: Wrapper(), withObject: nil)

// we never invalidate the timer, even when the view reaches the maximum generation, because it's hard to access the timer object from that scope

