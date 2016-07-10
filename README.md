# SwiftLife
A Game of Life implementation in Swift

There's a basic implementation of the game of life logic, with text and NSView-based visualisations.

There's no wraparound - there's a topology enum, but I haven't implemented the Torus code yet.

# Known Issues

It turns out that playgrounds in Xcode are a bit buggy. And they leak memory like a sieve. (Or maybe I'm a terrible Swift programmer.)

Don't try and run large games of life for long periods of time.
Be prepared for Xcode (or its child processes) to crash.

