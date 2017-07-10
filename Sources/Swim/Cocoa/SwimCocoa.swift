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

import Cocoa

public class SwimCocoa: SwimProtocol {
    
    private static let appDelegate = SwimCocoaAppDelegate()
    private var mainWindow: SwimWindow?
    private var eventQueue = [SwimEvent]()
    
    static let app: SwimCocoaApplication = {
        // This is static, as the underlying NSApplication should only be
        // created and launched once
        let app = SwimCocoaApplication.shared as! SwimCocoaApplication
        assert(NSApp != nil)
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.delegate = appDelegate
        NSApp.finishLaunching()
        return app
    }()
    
    // MARK: Initialization
    
    internal init() {
        _ = SwimCocoa.app
        createAppMenus()
    }
    
    // MARK: Application Menus
    
    private func createAppMenus() {
        let menuBar = NSMenu()
        
        let appMenuItem = NSMenuItem()
        menuBar.addItem(appMenuItem)
        
        let appMenu = NSMenu()
        let toggleFullscreenItem = NSMenuItem(title: "Toggle Full Screen", action: nil, keyEquivalent: "")
        toggleFullscreenItem.target = self
        appMenu.addItem(toggleFullscreenItem)
        
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitMenuItem.target = self
        appMenu.addItem(quitMenuItem)
        
        appMenuItem.submenu = appMenu
        
        NSApp.mainMenu = menuBar
        
    }
    
    // MARK: Window Management
    
    public func createWindow(size: SwimSize, title: String) -> SwimWindow {
        let frame = NSRect(x: 0, y: 0, width: CGFloat(size.width), height: CGFloat(size.height))
        let window = SwimCocoaWindow(contentRect: frame,
                                     styleMask: [.resizable, .closable, .titled],
                                     backing: .buffered,
                                     defer: true)
        window.makeKeyAndOrderFront(nil)
        return window
    }
    
    @objc func minimizeWindow() {
        
    }
    
    @objc internal func quit() {
        sendEvent(.quit)
    }
    
    // MARK: Event Management
    
    private func pollCocoaEvents() {
        var event: NSEvent?
        
        repeat {
            event = NSApp.nextEvent(matching: .any, until: Date.distantPast, inMode: .defaultRunLoopMode, dequeue: true)
            
            guard let e = event else {
                continue
            }
            
            handleCocoaEvent(e)
            
            NSApp.sendEvent(e)
        } while event != nil
    }
    
    internal func handleCocoaEvent(_ e: NSEvent) {
        switch e.type {
        case .keyDown:
            sendEvent(.keyDown(keyCode: e.keyCode))
        case .keyUp:
            sendEvent(.keyUp(keyCode: e.keyCode))
        case .mouseMoved:
            let window = (e.window as? SwimCocoaWindow)
            sendEvent(.mouseMoved(delta: (x: Double(e.deltaX), y: Double(e.deltaY)),
                                  absolute: (x: Double(e.locationInWindow.x), y: Double(e.locationInWindow.y)),
                                  window: window))
        case .leftMouseUp:
            sendEvent(.mouseUp(.left))
        case .leftMouseDown:
            sendEvent(.mouseDown(.left))
        case .leftMouseDragged:
            sendEvent(.mouseDragged(.left))
        case .rightMouseUp:
            sendEvent(.mouseUp(.right))
        case .rightMouseDown:
            sendEvent(.mouseDown(.right))
        case .rightMouseDragged:
            sendEvent(.mouseDragged(.right))
        default:
            break
        }
    }
    
    public func sendEvent(_ event: SwimEvent) {
        eventQueue.append(event)
    }
    
    public func pollEvent() -> SwimEvent? {
        pollCocoaEvents()
        
        if eventQueue.count > 0 {
            return eventQueue.removeFirst()
        }
        
        return nil
    }
}


