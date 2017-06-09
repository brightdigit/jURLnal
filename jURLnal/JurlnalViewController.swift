//
//  JurlnalViewController.swift
//  Jurlnal
//
//  Created by Leo Dion on 6/2/17.
//  Copyright © 2017 Leo Dion. All rights reserved.
//

import Cocoa
import ScriptingBridge

class JurlnalViewController: NSViewController {
  @IBOutlet weak var windowsPopUpButton: NSPopUpButton!
  
  var windowDictionary : [String: SafariWindow]?
  var safariApplication : SafariApplication?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    let safariApplication = SBApplication(bundleIdentifier: "com.apple.Safari")! as SafariApplication
    let safariWindows = safariApplication.windows?().flatMap({ $0 as? SafariWindow })
    if let safariWindows = safariWindows {
      let windowDictionary = safariWindows.reduce([String: SafariWindow](), { (dictionary, safariWindow) -> [String: SafariWindow] in
        guard let name = safariWindow.name else {
          return dictionary
        }
        var dictionary = dictionary
        dictionary[name] = safariWindow
        return dictionary
      })
      self.windowsPopUpButton.removeAllItems()
      self.windowsPopUpButton.addItems(withTitles: [String](windowDictionary.keys))
      self.windowDictionary = windowDictionary
      self.safariApplication = safariApplication
    }
  }
  
  @IBAction func applyAction (_ button: NSButton) {
    guard let selectedItem = self.windowsPopUpButton.selectedItem, let windowDictionary = self.windowDictionary else {
      return
    }
    
    guard let window = windowDictionary[selectedItem.title] else {
      return
    }
    
    guard let tabs = window.tabs?() else {
      return
    }
    
    let urls : [NSURL] = tabs.flatMap{
      let tab = $0 as? SafariTab
      
      guard let urlString = tab?.URL else {
        return nil
      }
      return NSURL(string: urlString)
    }
    
    NSPasteboard.general().clearContents()
    
    if !NSPasteboard.general().writeObjects(urls) {
      fatalError()
    }
    
    if !NSPasteboard.general().writeObjects(urls.map{ NSString(string: $0.absoluteString!) }) {
      fatalError()
    }
  }
}
