//
//  ViewController.swift
//  Folder_Info
//
//  Created by Liubomyr Havronskyi on 16.11.2019.
//  Copyright © 2019 Liubomyr Havronskyi. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    //@IBOutlet weak var fieldForJSON: NSTextField!
    
    @IBOutlet weak var path: NSTextField!
   // @IBOutlet weak var result: NSClipView!
    @IBOutlet weak var result: NSTextField!
    
    @IBAction func chooseFolder(_ sender: Any) {
       
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                
                self.selectedFolder = panel.urls[0]
            }
        }
    }
    
    var selectedFolder: URL? {
        didSet {
            
            guard let folderURL = selectedFolder else {
                
                path.stringValue = "incorrect folder"
                return
            }
            path.stringValue = folderURL.absoluteString
            
            guard Folder.info(folderURL) != nil else {
                
                path.stringValue = "Can't get info. Please try again"
                return
            }
            
            guard let folder = Folder(folderURL)  else {
                
                return
            }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            guard let data = try? encoder.encode(folder) else {
                
                path.stringValue = "Can't show in JSON"
                return
            }
            result.stringValue = String(data: data, encoding: .utf8) ?? ""
            
        }
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            
        }
    }
    
    
}


extension Folder {
    
    static func info ( _ url: URL?) -> String? {
        
        guard let localUrl = url else { return nil }
        
        guard let folder = Folder(localUrl) else { return nil }
        
        guard let encodeData =  try? JSONEncoder().encode(folder) else { return nil }
        
        guard let jsonString = String(data: encodeData, encoding: String.Encoding.utf8) else { return nil }
        return jsonString
    }

}
