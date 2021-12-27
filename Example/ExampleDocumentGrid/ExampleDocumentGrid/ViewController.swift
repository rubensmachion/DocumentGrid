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
    
    public override func didAddNew(item: DocumentGridItem) {
        self.uploadManager(item: item) { progress in
            self.uploadItem(item: item, progress: progress)
        }
    }
    
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

extension TestDocumentGridViewController {
    
    private func uploadManager(item: DocumentGridItem, progress: @escaping ProgressBlock) {
        DispatchQueue.global(qos: .background).async {
            var prog = 0.0
            forLoop: for i in 0...100 {
                sleep(1)
                prog = (Double(i)/Double(100))*Double(i)
                print("Thread: \(Thread.current), progress: \(prog)")
                if prog >= 1.0 {
                    DispatchQueue.main.async {
                        progress(prog)
                    }
                    break forLoop
                } else {
                    DispatchQueue.main.async {
                        progress(prog)
                    }
                }
            }
        }
    }
}
