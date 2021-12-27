//
//  File.swift
//  
//
//  Created by Rubens Machion on 27/12/21.
//

import Foundation
import UIKit

extension UIViewController {
    
    public func showUIImagePicker(sourceType: UIImagePickerController.SourceType,
                                  allowsEditing: Bool = true,
                                  delegate: (UINavigationControllerDelegate & UIImagePickerControllerDelegate)) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let i = UIImagePickerController()
            i.delegate = delegate
            i.sourceType = sourceType
            i.allowsEditing = allowsEditing
            
            self.present(i, animated: true, completion: nil)
        } else {
#if targetEnvironment(simulator)
            self.showUIImagePicker(sourceType: .photoLibrary,
                                   allowsEditing: allowsEditing,
                                   delegate: delegate)
#endif
        }
    }
}

extension DocumentGridViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: {
            var item: DocumentGridItem!
            if let url = info[.imageURL] as? URL {
                item = DocumentGridItem(document: Document(fileURL: url))
                self.addNewItem(item: item)
            } else {
                var image: UIImage!
                if info[.editedImage] != nil {
                    image = info[.editedImage] as? UIImage
                } else {
                    image = info[.originalImage] as? UIImage
                }
             
                guard image != nil else {
                    return
                }
                item = DocumentGridItem(image: image)
                self.addNewItem(item: item)
            }
        })
    }
}
