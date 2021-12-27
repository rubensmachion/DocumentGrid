//
//  ViewController.swift
//  ExampleDocumentGrid
//
//  Created by Rubens Machion on 22/12/21.
//

import UIKit
import DocumentGrid

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actionShowDocumentGrid(_ sender: Any?) {
        let vc = TestDocumentGridViewController(with: [
            .camera,
            .galery,
            .document
        ])
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: -
final public class TestDocumentGridViewController: DocumentGridViewController {
    
//    public override func openCamera(controller: DocumentGridViewController) {
//        self.showUIImagePicker(sourceType: .camera,
//                               allowsEditing: true,
//                               delegate: self)
//    }
//
//    public override func openGalery(controller: DocumentGridViewController) {
//        self.showUIImagePicker(sourceType: .photoLibrary,
//                               allowsEditing: false,
//                               delegate: self)
//    }
//
//    public override func openDocument(controller: DocumentGridViewController) {
//        self.showFiles()
//    }
    
    public override func canRemoveItem(item: DocumentGridItem, completion: @escaping ((Bool) -> ())) {
        
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
