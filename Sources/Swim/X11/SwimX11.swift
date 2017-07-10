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

class SwimX11Window: SwimWindow {
    private let windowId: UInt32
    let connection: OpaquePointer
    
    var size: SwimSize {
        get {
            return SwimSize(0, 0)
        }
        
        set {
            xcb_configure_window(connection,
                                 windowId,
                                 UInt16(XCB_CONFIG_WINDOW_WIDTH.rawValue | XCB_CONFIG_WINDOW_HEIGHT.rawValue),
                                 [UInt32(newValue.width), UInt32(newValue.height)])
        }
    }
    
    var title: String {
        get {
            let cookie = xcb_get_property(connection,
                             0,
                             windowId,
                             XCB_ATOM_WM_NAME.rawValue,
                             XCB_ATOM_STRING.rawValue,
                             0,
                             0)
            
            let reply = xcb_get_property_reply(connection, cookie, nil)
            
            if reply != nil {
                let name = xcb_get_property_value(reply)
                let nameString = String(cString: UnsafePointer<CChar>(name!.assumingMemoryBound(to: CChar.self)))
                return nameString
            }
            
            return ""
        }
        
        set {
            xcb_change_property(connection,
                                UInt8(XCB_PROP_MODE_REPLACE.rawValue),
                                windowId,
                                XCB_ATOM_WM_NAME.rawValue,
                                XCB_ATOM_STRING.rawValue,
                                8,
                                UInt32(newValue.count),
                                newValue.cString(using: .utf8))
            xcb_flush(connection)
        }
    }
    
    init(connection: OpaquePointer!, screen: UnsafeMutablePointer<xcb_screen_t>, size: SwimSize, title: String) {
        self.connection = connection
        windowId = xcb_generate_id(connection)
        xcb_create_window(connection,
                          UInt8(XCB_COPY_FROM_PARENT),
                          windowId,
                          screen.pointee.root,
                          0,
                          0,
                          UInt16(size.width),
                          UInt16(size.height),
                          10,
                          UInt16(XCB_WINDOW_CLASS_INPUT_OUTPUT.rawValue),
                          screen.pointee.root_visual,
                          0,
                          nil)
        
        xcb_map_window(connection, windowId)
        xcb_flush(connection)
        
        self.title = title
        
        //xcb_configure_window(connection, windowId, UInt16(XCB_CONFIG_WINDOW_WIDTH.rawValue | XCB_CONFIG_WINDOW_HEIGHT.rawValue), [UInt32(320), UInt32(240)])
        //xcb_flush(connection)
    }
    
    func isEqual(_ window: SwimWindow) -> Bool {
        return false
    }
}

class SwimX11: SwimProtocol {
    let connection: OpaquePointer
    let screen: UnsafeMutablePointer<xcb_screen_t>
    
    init() {
        connection = xcb_connect(nil, nil)
        
        let setup = xcb_get_setup(connection)
        let iterator = xcb_setup_roots_iterator(setup)
        screen = iterator.data
    }
    
    deinit {
        xcb_disconnect(connection)
    }
    
    func createWindow(size: SwimSize, title: String) -> SwimWindow {
        return SwimX11Window(connection: connection, screen: screen, size: size, title: title)
    }
    
    func sendEvent(_ e: SwimEvent) {
    }
    
    func pollEvent() -> SwimEvent? {
        return nil
    }
    
    
}
