//
//  File.swift
//  
//
//  Created by Rubens Machion on 27/12/21.
//

import UIKit
import MobileCoreServices

// MARK: - UIDocumentPickerDelegate
extension DocumentGridViewController: UIDocumentPickerDelegate {
    
    public func showFiles() {
        
        let documentVc = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF), String(kUTTypePNG)],
                                                        in: .import)
        documentVc.delegate = self
        documentVc.allowsMultipleSelection = false
        
        self.present(documentVc, animated: true, completion: nil)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController,
                               didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true, completion: nil)
        guard controller.documentPickerMode == .import, let url = urls.first/*, url.startAccessingSecurityScopedResource()*/ else { return }

        let item = DocumentGridItem(pdf: url)
        self.addNewItem(item: item)
    }
}
