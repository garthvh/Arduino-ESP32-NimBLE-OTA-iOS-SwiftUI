//
//  Extensions.swift
//  MeshtasticFlasherESP32
//
//  Created by Garth Vander Houwen on 12/5/22.
//
import SwiftUI

extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}
