//
//  ViewController.swift
//  ExampleDocumentGrid
//
//  Created by Rubens Machion on 22/12/21.
//

import UIKit
import DocumentGrid
import MobileCoreServices

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func actionShowDocumentGrid(_ sender: Any?) {
        let vc = TestDocumentGridViewController(with: [
            .camera, .galery, .document
        ])
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: -
final public class TestDocumentGridViewController: DocumentGridViewController {
    
    public override func openCamera(controller: DocumentGridViewController) {
        self.showUIImagePicker(sourceType: .camera)
    }
    
    public override func openGalery(controller: DocumentGridViewController) {
        self.showUIImagePicker(sourceType: .photoLibrary, allowsEditing: false)
    }
    
    public override func openDocument(controller: DocumentGridViewController) {
        self.showFiles()
    }
    
    public override func willRemoveItem(item: DocumentGridItem, completion: @escaping ((Bool) -> ())) {
        
        self.showAlert(title: "Atenção",
                       message: "Tem certeza que deseja remover este arquivo?",
                       style: .alert,
                       actions: [
                        UIAlertAction(title: "Sim",
                                      style: .destructive,
                                      handler: { _ in
                                          completion(true)
                                      }),
                        UIAlertAction(title: "Não",
                                      style: .cancel,
                                      handler: nil)
                       ])
    }
}

// MARK: - Galery
extension TestDocumentGridViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showUIImagePicker(sourceType: UIImagePickerController.SourceType, allowsEditing: Bool = true) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let i = UIImagePickerController()
            i.delegate = self
            i.sourceType = sourceType
            i.allowsEditing = allowsEditing
            
            self.present(i, animated: true, completion: nil)
        } else {
            #if targetEnvironment(simulator)
            self.showUIImagePicker(sourceType: .photoLibrary,
                                   allowsEditing: allowsEditing)
            #endif
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: {
            var image: UIImage!
            if info[.editedImage] != nil {
                image = info[.editedImage] as? UIImage
            } else {
                image = info[.originalImage] as? UIImage
            }
            guard image != nil else {
                return
            }
            let item = DocumentGridItem(image: image)
            self.addNewItem(item: item)
        })
    }
}

// MARK: - iCloudDrive
extension TestDocumentGridViewController: UIDocumentPickerDelegate {
    
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
    }
}
