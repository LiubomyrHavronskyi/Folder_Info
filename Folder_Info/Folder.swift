//
//  Image.swift
//  Folder_Info
//
//  Created by Liubomyr Havronskyi on 16.11.2019.
//  Copyright © 2019 Liubomyr Havronskyi. All rights reserved.
//

import Foundation

final class Folder {
    
    private let name: String
    private let dateOfCreation: String
    private let files: [File]?
    private let childrens: [Folder]?
    
    enum  CodingKeys: String, CodingKey{
        
        case name = "Name"
        case date = "DateCreated"
        case files = "Files"
        case childrens = "Children"
        
    }
    
    init( _ inputName: String, _ inputDateCreated: String, _ inputFiles: [File]?, _ inputChildrens: [Folder]? ) {
        
        name = inputName
        dateOfCreation = inputDateCreated
        files = inputFiles
        childrens = inputChildrens
    
    }
    
    convenience
    init( _ inputFolder: Folder) {
        
        self.init(inputFolder.name, inputFolder.dateOfCreation, inputFolder.files, inputFolder.childrens)
        
    }
    
    
    
    
}

extension Folder {
    
    convenience
    init? ( _ url: URL?) {
        
        guard  let localUrl = url else {
            return nil
        }
        
        let nameToSet: String = localUrl.lastPathComponent
        let dateToSet: String
        
        do {
            
            let attributes = try FileManager.default.attributesOfItem(atPath: localUrl.path)
            guard  let indexOfCreationDate = attributes.index(forKey: FileAttributeKey(rawValue: "NSFileCreationDate")) else { return nil }
            dateToSet = "\(attributes[indexOfCreationDate].value)"
            
        } catch {
            
            return nil
        }
        
        
        guard let fileToSet: [File] = Folder.getFilesFrom(localUrl),
            let childrensToSet: [Folder] = Folder.getChildrenFoldersFrom(localUrl) else {
                return nil
        }
        
        
        self.init(nameToSet, dateToSet, fileToSet, childrensToSet)
        
    }
    
    static func getChildrenFoldersFrom (_ url: URL?) -> [Folder]? {
        
        var childrenFolders: [Folder]? = []
        
        guard let localUrl = url else {
            
            return nil
        }
        
        do {
            
            let contents = try FileManager.default.contentsOfDirectory(atPath: localUrl.path)
            let urls = contents.map { return localUrl.appendingPathComponent($0) }
            
            urls.forEach { (element) in
                
                do {
                    
                    let attributes = try FileManager.default.attributesOfItem(atPath: element.path)
                    guard  let indexOfFileType = attributes.index(forKey: FileAttributeKey(rawValue: "NSFileType")) else {
                        childrenFolders = nil
                        return
                    }
                    
                    if "\(attributes[indexOfFileType].value)" == "NSFileTypeDirectory"{
                        
                        guard let newFolder = Folder(element) else {
                            
                            return
                        }
                        
                        childrenFolders?.append(newFolder)
                    }
                    
                } catch {
                    
                    childrenFolders = nil
                }
            }
            
        } catch {
            
            return nil
        }
        
        return childrenFolders
    }
    
    static func getFilesFrom ( _ url: URL?) -> [File]? {
        
        var files: [File]? = []
        
        guard let localUrl = url else {
            
            return nil
        }
        
        do {
            
            let contents = try FileManager.default.contentsOfDirectory(atPath: localUrl.path)
            let urls = contents.map { return localUrl.appendingPathComponent($0) }
            
            urls.forEach { (element) in
                
                do {
                    
                    let attributes = try FileManager.default.attributesOfItem(atPath: element.path)
                    guard  let indexOfFileType = attributes.index(forKey: FileAttributeKey(rawValue: "NSFileType")) else {
                        files = nil
                        return
                    }
                    
                    if "\(attributes[indexOfFileType].value)" != "NSFileTypeDirectory" {
                        
                        guard let newFile = File(element) else {
                            
                            return
                        }
                        files?.append(newFile)
                    }
                    
                } catch {
                    
                    files = nil
                }
            }
            
        } catch {
            
            return nil
        }
        
        return files
    }
}

extension Folder: CustomStringConvertible {
    
    var description: String {
        
        var stringForFiles: String = ""
        self.files?.forEach({ (element) in
            
            stringForFiles += "\(element)"
        
        })
        stringForFiles.removeLast()
        
        var stringForFolders: String = " "
        self.childrens?.forEach({ (element) in
            
            stringForFolders += "\(element) "
        })
        stringForFolders.removeLast()
        
        
        return """
            Name: \(self.name),
            DateCreated: \(self.dateOfCreation),
            Files: [\(stringForFiles)],
            ChildrensOf: [\(stringForFolders)]
        """
        
    }
}

extension Folder: Codable {
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(files, forKey: .files)
        try container.encode(childrens, forKey: .childrens)
        try container.encode(dateOfCreation, forKey: .date)
    }
    
    convenience
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nameToSet = try container.decode(String.self, forKey: .name)
        let filesToSet = try container.decode([File].self, forKey: .files)
        let childrensToSet = try container.decode([Folder].self, forKey: .childrens)
        let dateToSet = try container.decode(String.self, forKey: .date)
        
        self.init(nameToSet, dateToSet, filesToSet, childrensToSet)
    }
}



