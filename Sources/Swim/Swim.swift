/*
 
 MIT License
 
 Copyright (c) 2017 Andy Best
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import Foundation

public enum SwimError: Error {
    case general(String)
}

public protocol SwimProtocol {
    func createWindow(size: SwimSize, title: String) -> SwimWindow
    func sendEvent(_ e: SwimEvent)
    func pollEvent() -> SwimEvent?
}

public struct SwimSize {
    var width: Double
    var height: Double
    
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    public init(_ width: Double, _ height: Double) {
        self.width = width
        self.height = height
    }
}

public protocol SwimWindow {
    var size: SwimSize { get set }
    var title: String { get set }
    func isEqual(_ window: SwimWindow) -> Bool
}

public func ==<T: SwimWindow>(lhs: T, rhs: T) -> Bool {
    return lhs.isEqual(rhs)
}

public enum SwimMouseButton {
    case left
    case right
    case middle
}

public enum SwimEvent {
    case quit
    case keyDown(keyCode: UInt16)
    case keyUp(keyCode: UInt16)
    case mouseMoved(delta: (x: Double, y: Double), absolute: (x: Double, y: Double), window: SwimWindow?)
    case mouseUp(SwimMouseButton)
    case mouseDown(SwimMouseButton)
    case mouseDragged(SwimMouseButton)
    case windowClosed(SwimWindow)
}

public struct Swim {
    public static let shared: SwimProtocol = {
        #if os(OSX)
            do {
                return try SwimX11()//SwimCocoa()
            } catch {
                fatalError(String(describing: error))
            }
        #else
            fatalError("Unsupported Swim platform!")
        #endif
    }()
}
