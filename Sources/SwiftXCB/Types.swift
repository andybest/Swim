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

import CXCB


enum SwiftXCBError: Error {
    case cannotConnect
    case general(String)
}


public struct XCBSize {
    public var width: Int
    public var height: Int
    
    public init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height
    }
}

public enum XCBMouseButton {
    case left
    case right
    case middle
    
    init?(xcbButton: xcb_button_t) {
        switch xcbButton {
        case 1:
            self = .left
            
        case 2:
            self = .middle
            
        case 3:
            self = .right
            
        default: return nil
        }
    }
}

public enum XCBEvent {
    case quit
    case keyDown(keyCode: UInt16)
    case keyUp(keyCode: UInt16)
    //case mouseMoved(delta: (x: Double, y: Double), absolute: (x: Double, y: Double), window: SwimWindow?)
    case mouseUp(XCBMouseButton)
    case mouseDown(XCBMouseButton)
    case mouseDragged(XCBMouseButton)
    case windowClosed(XCBMouseButton)
}
