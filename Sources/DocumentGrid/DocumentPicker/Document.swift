//
//  Document.swift
//  
//
//  Created by Rubens Machion on 23/12/21.
//

import UIKit

final public class Document: UIDocument {
    
    var data: Data?
    
    public override func contents(forType typeName: String) throws -> Any {
        guard let data = data else { return Data() }
        return try NSKeyedArchiver.archivedData(withRootObject:data,
                                                requiringSecureCoding: true)
    }
    public override func load(fromContents contents: Any, ofType typeName:
                       String?) throws {
        guard let data = contents as? Data else { return }
        self.data = data
    }
}
