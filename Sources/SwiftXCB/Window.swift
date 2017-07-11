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
import CXCB


public class XCBWindow {
    private let connection: OpaquePointer
    private let windowId: UInt32
    
    // MARK: Properties
    
    public var size: XCBSize {
        get {
            return XCBSize(0, 0)
        }
        
        set {
            xcb_configure_window(connection,
                                 windowId,
                                 UInt16(XCB_CONFIG_WINDOW_WIDTH.rawValue | XCB_CONFIG_WINDOW_HEIGHT.rawValue),
                                 [UInt32(newValue.width), UInt32(newValue.height)])
        }
    }
    
    public var title: String {
        get {
            do {
                return try getStringProperty(atom: XCB_ATOM_WM_NAME)
            } catch {
                return ""
            }
        }
        
        set {
            do {
                try setProperty(atom: XCB_ATOM_WM_NAME, value: newValue)
            } catch {
                fatalError(String(describing: error))
            }
        }
    }
    
    // MARK: Initialization
    
    internal init(connection: OpaquePointer, screen: xcb_screen_t, size: XCBSize) {
        self.connection = connection
        windowId = xcb_generate_id(connection)
        
        let valueMask = XCB_CW_EVENT_MASK.rawValue
        let eventList = [
            XCB_EVENT_MASK_KEY_PRESS.rawValue |
                XCB_EVENT_MASK_KEY_RELEASE.rawValue |
                XCB_EVENT_MASK_POINTER_MOTION.rawValue |
                XCB_EVENT_MASK_BUTTON_PRESS.rawValue |
                XCB_EVENT_MASK_BUTTON_RELEASE.rawValue
        ]
        
        xcb_create_window(connection,
                          UInt8(XCB_COPY_FROM_PARENT),
                          windowId,
                          screen.root,
                          0,
                          0,
                          UInt16(size.width),
                          UInt16(size.height),
                          10,
                          UInt16(XCB_WINDOW_CLASS_INPUT_OUTPUT.rawValue),
                          screen.root_visual,
                          valueMask,
                          eventList)
        
        xcb_map_window(connection, windowId)
        xcb_flush(connection)
    }
    
    // MARK: XCB Property Wrappers
    
    internal func getStringProperty(atom: xcb_atom_enum_t) throws -> String {
        guard let str = try getProperty(atom: atom, type: XCB_ATOM_STRING) as? String else {
            throw SwiftXCBError.general("Unable to coerce reply to string")
        }
        
        return str
    }
    
    internal func getProperty(atom: xcb_atom_enum_t, type: xcb_atom_enum_t) throws -> Any {
        let cookie = xcb_get_property(connection,
                                      0,
                                      windowId,
                                      atom.rawValue,
                                      type.rawValue,
                                      0,
                                      0)
        
        let reply = xcb_get_property_reply(connection, cookie, nil)
        
        guard let rep = reply, let propVal = xcb_get_property_value(rep) else {
            throw SwiftXCBError.general("Unable to get window property")
        }
        
        switch type {
        case XCB_ATOM_STRING:
            return String(cString: UnsafePointer<CChar>(propVal.assumingMemoryBound(to: CChar.self)))
        default:
            throw SwiftXCBError.general("Unknown type")
        }
    }
    
    internal func setProperty<T>(atom: xcb_atom_enum_t, value: T) throws {
        
        switch T.self {
        case is String.Type:
            let v = value as! String
            xcb_change_property(connection,
                                UInt8(XCB_PROP_MODE_REPLACE.rawValue),
                                windowId,
                                atom.rawValue,
                                XCB_ATOM_STRING.rawValue,
                                8,
                                UInt32(v.count),
                                v.cString(using: .utf8))
        default:
            throw SwiftXCBError.general("Unhandled type: \(T.self)")
        }
        
        xcb_flush(connection)
    }
}
