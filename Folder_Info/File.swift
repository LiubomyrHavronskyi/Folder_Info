//
//  ClassFile.swift
//  Folder_Info
//
//  Created by Liubomyr Havronskyi on 16.11.2019.
//  Copyright © 2019 Liubomyr Havronskyi. All rights reserved.
//

import Foundation

final class File {
    
    private let name: String
    private let size: String
    private let path: String
    
    enum  CodingKeys: String, CodingKey{
        
        case name = "Name"
        case size = "Size"
        case path = "Path"
    }
    
    init( _ inputName: String, _ inputSize: String, _ inputPath: String) {
        
        name = inputName
        size = inputSize
        path = inputPath
    }
}

extension File {
    
    convenience
    init? (_ url : URL?) {
        
        guard let localUrl = url else {
            return nil
        }
        
        let nameToSet: String = localUrl.lastPathComponent
        let sizeToSet: String
        
        do {
            
            let attributes = try FileManager.default.attributesOfItem(atPath: localUrl.path)
            
            guard let indexOfSize = attributes.index(forKey: FileAttributeKey(rawValue: "NSFileSize")) else {
                return nil
            }
            
            let sizeInB: Double = (Double("\(attributes[indexOfSize].value)") ?? 0) / 8
            sizeToSet = "\(sizeInB) B"
            
        } catch {
            return nil
        }
        
        let pathToSet: String = localUrl.path
        
        self.init(nameToSet, sizeToSet, pathToSet)
    }
}

extension File: CustomStringConvertible {
    
    var description: String {
        
        return """
            name:\(self.name),
            size:\(self.size),
            path:\(self.path)
        """
    }
}


extension File: Codable {
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(size, forKey: .size)
        try container.encode(path, forKey: .path)
    }
    
    convenience
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nameToSet = try container.decode(String.self, forKey: .name)
        let pathToSet = try container.decode(String.self, forKey: .path)
        let sizeToSet = try container.decode(String.self, forKey: .size)
        
        self.init(nameToSet, sizeToSet, pathToSet)
    }
    
}
