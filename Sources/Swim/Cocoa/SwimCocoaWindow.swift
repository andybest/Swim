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

internal class SwimCocoaWindow: NSWindow, NSWindowDelegate, SwimWindow {
    func isEqual(_ window: SwimWindow) -> Bool {
        if let w = window as? SwimCocoaWindow {
            return self == w
        }
        return false
    }
    
    var size: SwimSize {
        set {
            var frame = self.frame
            frame.size.width = CGFloat(size.width)
            frame.size.height = CGFloat(size.height)
            self.setFrame(frame, display: true)
        }
        
        get {
            return SwimSize(width: Double(self.frame.width),
                            height: Double(self.frame.height))
        }
    }
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        self.delegate = self
        updateTrackingArea(bounds: self.frame)
    }
    
    private func updateTrackingArea(bounds: NSRect) {
        let area = NSTrackingArea(rect: bounds,
                                  options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited, .mouseMoved],
                                  owner: self,
                                  userInfo: nil)
        
        if let view = self.contentView, view.trackingAreas.count > 0 {
            for a in view.trackingAreas {
                view.removeTrackingArea(a)
            }
        }
        
        self.contentView?.addTrackingArea(area)
    }
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        updateTrackingArea(bounds: NSRect(origin: .zero, size: frameSize))
        
        return frameSize
    }
    
    func windowWillClose(_ notification: Notification) {
        Swim.shared.sendEvent(.windowClosed(self))
    }
}
