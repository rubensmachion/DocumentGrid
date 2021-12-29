//
//  File.swift
//  
//
//  Created by Rubens Machion on 29/12/21.
//

import UIKit
import QuickLook

extension DocumentGridViewController {
    func openPreviewAt(index: IndexPath) {
        let vc = QLPreviewController()
        vc.dataSource = self
        vc.delegate = self
        vc.currentPreviewItemIndex = index.item
        self.present(vc, animated: true, completion: nil)
    }
}

extension DocumentGridViewController: QLPreviewControllerDataSource {
    
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return self.numberOfItems()
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.itemAt(indexPath: IndexPath(item: index, section: 0))
    }
}

extension DocumentGridViewController: QLPreviewControllerDelegate {
    
    @available(iOS 13.0, *)
    public func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        return .disabled
    }
}
