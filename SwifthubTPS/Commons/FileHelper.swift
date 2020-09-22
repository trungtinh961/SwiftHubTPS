//
//  FileHelper.swift
//  SwifthubTPS
//
//  Created by TPS on 9/22/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation

class FileHelper {
    static func saveJSON(_ data: Data, filename: String) {
        guard let fileURL = dataFilePath(filename) else { return }
        do {
            let json = String(data: data, encoding: .utf8)
            try json!.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch {
            debugPrint("Error save json: \(error.localizedDescription)")
        }
    }
    
    static func loadJSON(filename: String) -> Data? {
        guard let fileURL = dataFilePath(filename) else { return nil }
        if let data = try? Data(contentsOf: fileURL) {
            return data
        }        
        return nil
    }
    
    static func dataFilePath(_ filename: String) -> URL? {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            var fileURL = url.appendingPathComponent(filename)
            fileURL = fileURL.appendingPathExtension("json")
            return fileURL
        }
        return nil
    }
}
