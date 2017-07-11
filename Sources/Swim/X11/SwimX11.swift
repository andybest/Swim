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

import SwiftXCB

extension SwimSize {
    init(_ xcbSize: XCBSize) {
        self.width = Double(xcbSize.width)
        self.height = Double(xcbSize.height)
    }
    
    func xcbSize() -> XCBSize {
        return XCBSize(Int(self.width), Int(self.height))
    }
}

extension XCBMouseButton {
    func toSwimButton() -> SwimMouseButton {
        switch self {
        case .left:
            return .left
        case .right:
            return .right
        case .middle:
            return .middle
        }
    }
}

extension XCBEvent {
    func toSwimEvent() -> SwimEvent? {
        switch self {
        case .keyDown(keyCode: let keyCode): return .keyDown(keyCode: keyCode)
        case .keyUp(keyCode: let keyCode): return .keyUp(keyCode: keyCode)
        case .mouseDown(let button): return .mouseDown(button.toSwimButton())
        case .mouseUp(let button): return .mouseDown(button.toSwimButton())
        case .mouseMoved(x: let x, y: let y): return .mouseMoved(delta: (x: 0, y: 0), absolute: (x: Double(x), y: Double(y)), window: nil)
            
        default: return nil
        }
    }
}

class SwimX11Window: SwimWindow {
    internal let window: XCBWindow
    
    var size: SwimSize {
        get { return SwimSize(window.size) }
        set { window.size = newValue.xcbSize() }
    }
    
    var title: String {
        get { return window.title }
        set { window.title = newValue }
    }
    
    init(window: XCBWindow) {
        self.window = window
    }
    
    func isEqual(_ window: SwimWindow) -> Bool {
        return false
    }
}

class SwimX11: SwimProtocol {
    let xcb: SwiftXCB
    
    init() throws {
        do {
            xcb = try SwiftXCB()
        } catch {
            throw SwimError.general("Unable to create XCB connection")
        }
    }
    
    func createWindow(size: SwimSize, title: String) -> SwimWindow {
        let xcbwindow = xcb.createGLWindow(size: size.xcbSize())
        
        let window = SwimX11Window(window: xcbwindow)
        window.title = title
        
        return window
    }
    
    func sendEvent(_ e: SwimEvent) {
    }
    
    func pollEvent() -> SwimEvent? {
        return xcb.pollEvent()?.toSwimEvent()
    }
    
    
}
