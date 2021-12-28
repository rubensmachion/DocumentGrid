//
//  Document.swift
//  
//
//  Created by Rubens Machion on 23/12/21.
//

import UIKit

final public class Document: NSObject {
    
    var data: Data?
    var fileURL: URL!
    var fileType: String?
    
    public init(fileURL url: URL) {

        super.init()
        self.fileURL = url
        self.fileType = url.pathExtension
        if url.isFileURL {
            self.data = try? Data(contentsOf: url)
        }
    }
}
