//
//  JurlnalViewController.swift
//  Jurlnal
//
//  Created by Leo Dion on 6/2/17.
//  Copyright © 2017 Leo Dion. All rights reserved.
//

import Cocoa
import ScriptingBridge

extension Collection {
  func toDictionary<K, V>
    (_ transform:(_ element: Self.Generator.Element) -> (key: K, value: V)?) -> [K : V] {
    
    return self.reduce([:]) { ( dictionary, e) in
      var dictionary = dictionary
      if let (key, value) = transform(e){
        dictionary[key] = value
      }
      return dictionary
    }
  }
}

class JurlnalViewController: NSViewController {
  @IBOutlet weak var windowsPopUpButton: NSPopUpButton!
  
  var windows : [String: SafariWindow]! = nil
  var safariApplication : SafariApplication!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    let safariApplication = SBApplication(bundleIdentifier: "com.apple.Safari")! as SafariApplication
    self.windows = safariApplication.windows!().reduce([String: SafariWindow](), { (dictionary, object) -> [String: SafariWindow] in
      let window = object as! SafariWindow
      var dictionary = dictionary
      dictionary[window.name!] = window
      return dictionary
    })
    self.windowsPopUpButton.removeAllItems()
    self.windowsPopUpButton.addItems(withTitles: [String](self.windows.keys))
    self.safariApplication = safariApplication
  }
  
  @IBAction func applyAction (_ button: NSButton) {
    let window = self.windows[self.windowsPopUpButton.selectedItem!.title]
    
    let urls : [NSURL] = window!.tabs!().flatMap{
      let tab = $0 as! SafariTab
      
      guard let urlString = tab.URL else {
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
