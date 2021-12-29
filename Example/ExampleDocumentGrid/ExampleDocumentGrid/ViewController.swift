//
//  ViewController.swift
//  ExampleDocumentGrid
//
//  Created by Rubens Machion on 22/12/21.
//

import UIKit
import DocumentGrid

class ViewController: UIViewController {
    
    public var urlList: [String] = [
        "https://dev-compre-e-instale-images-public.s3.amazonaws.com/HELPER_PROFILE_IMG_1612891728423_3d3aa24b-2127-4296-be91-71ab3512ad26.jpg",
        "https://dev-compre-e-instale-images-public.s3.amazonaws.com/HELPER_PROFILE_IMG_1619530218240_740702cd-d951-416d-bef0-ceddee576379.jpg",
        "https://dev-compre-e-instale-images-public.s3.amazonaws.com/sample.pdf",
        "https://dev-compre-e-instale-images-public.s3.amazonaws.com/0B460561-F7A1-498C-9927-DC0072AAA648-94522-00002EA2DD0D929D.jpeg",
        "https://dev-compre-e-instale-images-public.s3.amazonaws.com/HELPIE_FILES_1613011439_5aed5c68-99fe-4d6b-aebf-bdc99eaafa5c.jpg",
        "https://dev-compre-e-instale-images-public.s3.amazonaws.com/437AF577-C9DD-476D-8CB9-EB1FBB0BC7BB-18108-00000F76B0F868B9.jpeg",
        "https://dev-compre-e-instale-images-public.s3.amazonaws.com/480421D4-9434-4298-B308-84FC9E09FEF0-5316-00000149514C7C1E.jpeg"
    ]
    
    @IBOutlet weak var buttonList: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.buttonList.setTitle("List (\(DocumentGridItems.shared.list.count))", for: .normal)
    }
    
    @IBAction func actionShowDocumentGrid(_ sender: Any?) {
        let vc = TestDocumentGridViewController(with: [
            .camera,
            .galery,
            .document
        ], clearList: false)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionShowEmptyList(_ sender: Any?) {
        let vc = TestDocumentGridViewController(with: [
            .camera,
            .galery,
            .document
        ], clearList: true)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionStartListWithData(_ sender: Any?) {
        let vc = TestDocumentGridViewController(with: [
            .camera,
            .galery,
            .document
        ], clearList: true)
        
        DocumentGridItems.shared.list = self.urlList.map({
            DocumentGridItem(document: Document(fileURL: URL(string: $0)!))
        })
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: -
final public class TestDocumentGridViewController: DocumentGridViewController {
    
    public override func didAddNew(item: DocumentGridItem) {
//        self.uploadManager(item: item) { progress in
//            self.uploadItem(item: item, progress: progress)
//        }
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
