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
import Foundation


public class SwiftXCB {
    let display: OpaquePointer
    let xScreen: Int32
    let connection: OpaquePointer
    let screen: xcb_screen_t
    var window: XCBGLWindow?
    
    // MARK: Initializers
    public init() throws {
        guard let display = XOpenDisplay(nil) else {
            throw SwiftXCBError.general("Cannot open display)")
        }
        
        self.display = display
        let defaultScreen = XDefaultScreen(display)
        
        guard let conn = XGetXCBConnection(display) else {
            throw SwiftXCBError.cannotConnect
        }
        
        connection = conn
        
        XSetEventQueueOwner(display, XCBOwnsEventQueue)
        
        guard let setup = xcb_get_setup(connection) else {
            throw SwiftXCBError.general("Cannot get setup")
        }
        
        // Get the first screen
        var iterator = xcb_setup_roots_iterator(setup)
        
        var screenNum = defaultScreen
        var scr = iterator.data
        while iterator.rem > 0 && screenNum > 0 {
            scr = iterator.data
            screenNum -= 1
            xcb_screen_next(&iterator)
        }
        
        xScreen = defaultScreen
        
        guard let s = scr else {
            throw SwiftXCBError.general("Unable to get first screen")
        }
        
        screen = s.pointee
    }
    
    deinit {
        XCloseDisplay(display)
    }
    
    // MARK: Window management
    
    public func createWindow(size: XCBSize) -> XCBWindow {
        let window = XCBWindow(connection: connection, screen: screen, size: size)
        return window
    }
    
    public func createGLWindow(size: XCBSize) -> XCBGLWindow {
        let window = XCBGLWindow(connection: connection, screen: screen, size: size, display: display, screenNum: xScreen)
        self.window = window
        return window
    }
    
    public func pollEvent() -> XCBEvent? {
        guard let e = xcb_poll_for_event(connection) else {
            return nil
        }
        
        let event = e.pointee
        
        let response = Int32(event.response_type)
        
        switch response
        {
        case XCB_KEY_PRESS:
            let keyEvent = e.withMemoryRebound(to: xcb_key_press_event_t.self, capacity: MemoryLayout<xcb_key_press_event_t>.size) {
                return $0.pointee
            }
            return XCBEvent.keyDown(keyCode: UInt16(keyEvent.detail))
            
        case XCB_KEY_RELEASE:
            let keyEvent = e.withMemoryRebound(to: xcb_key_press_event_t.self, capacity: MemoryLayout<xcb_key_press_event_t>.size) {
                return $0.pointee
            }
            return XCBEvent.keyUp(keyCode: UInt16(keyEvent.detail))
            
        case XCB_BUTTON_PRESS:
            let buttonEvent = e.withMemoryRebound(to: xcb_button_press_event_t.self, capacity: MemoryLayout<xcb_button_press_event_t>.size) {
                return $0.pointee
            }
            
            if let button = XCBMouseButton(xcbButton: buttonEvent.detail) {
                return XCBEvent.mouseDown(button)
            }
            
        case XCB_BUTTON_RELEASE:
            let buttonEvent = e.withMemoryRebound(to: xcb_button_press_event_t.self, capacity: MemoryLayout<xcb_button_press_event_t>.size) {
                return $0.pointee
            }
            
            if let button = XCBMouseButton(xcbButton: buttonEvent.detail) {
                return XCBEvent.mouseUp(button)
            }
            
        case XCB_MOTION_NOTIFY:
            let motionEvent = e.withMemoryRebound(to: xcb_motion_notify_event_t.self, capacity: MemoryLayout<xcb_motion_notify_event_t>.size) {
                return $0.pointee
            }
            
            return XCBEvent.mouseMoved(x: Int(motionEvent.event_x), y: Int(motionEvent.event_y))
            
        case XCB_EXPOSE:
            window?.draw()
            
        default:
            break
        }
        
        return nil
    }
}
