//
//  DocumentGridViewController.swift
//  CompraFacil_iOS
//
//  Created by Rubens Machion on 22/12/21.
//

import UIKit

// MARK: - DocumentGridViewControllerDelegate
public protocol DocumentGridViewControllerDelegate: AnyObject {
    
}

// MARK: - DocumentGridViewController
open class DocumentGridViewController: UIViewController {
    
    public enum DocumentGridAddOption {
        case camera
        case galery
        case document
    }
    
    private var documentGridAddOptions: [DocumentGridAddOption] = []
    
    private var list: [DocumentGridItem] = []
    
    // MARK: - Delegate
    public weak var delegate: DocumentGridViewControllerDelegate? = nil
    
    // MARK: - Views
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let padding = 5.0
        let size = Int((UIScreen.main.bounds.size.width / 3.0) - (padding * 2.0))
        
        $0.sectionInset = UIEdgeInsets(top: 10.0,
                                       left: padding,
                                       bottom: padding,
                                       right: padding)
        $0.itemSize = CGSize(width: size, height: size)
        $0.scrollDirection = .vertical
        
        return $0
    }(UICollectionViewFlowLayout())
    
    private lazy var documentColletionView: DocumentCollectionView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alwaysBounceVertical = true
        $0.allowsMultipleSelection = false
        $0.dataSource = self
        $0.delegate = self
        $0.register(DocumentCollectionViewCell.self,
                    forCellWithReuseIdentifier: DocumentCollectionViewCell.identifier)
        return $0
    }(DocumentCollectionView(frame: .zero,
                             collectionViewLayout: self.collectionViewLayout))
    
    // MARK: - Init
    public init(with options: [DocumentGridAddOption]) {
        super.init(nibName: nil, bundle: nil)
        self.documentGridAddOptions = options
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    // MARK: - Navigation
    @objc private func actionAddNew() {
        self.showAlertOption()
    }
    
    @objc private func longGesture(_ gesture: UIGestureRecognizer) {
        if gesture is UITapGestureRecognizer {
            if self.documentColletionView.allowsMultipleSelection {
                self.documentColletionView.allowsMultipleSelection = false
                self.documentColletionView.reloadData()
            }
        } else if gesture is UILongPressGestureRecognizer {
            switch gesture.state {
            case .began:
                if !self.documentColletionView.allowsMultipleSelection {
                    self.documentColletionView.allowsMultipleSelection = true
                } else {
                    self.documentColletionView.allowsMultipleSelection = false
                }
                self.documentColletionView.reloadData()
                break
            default:
                break
            }
        }
    }
    
    // MARK: - DataSource methods
    public func numberOfItems() -> Int {
        return self.list.count
    }
    
    public func itemAt(indexPath: IndexPath) -> DocumentGridItem {
        return self.list[indexPath.item]
    }
    
    public func addNewItem(item: DocumentGridItem) {
        self.list.append(item)
        let index = IndexPath(item: self.list.count - 1, section: 0)
        self.documentColletionView.insertItems(at: [index])
        self.didAddNew(item: item)
    }
    
    public func removeItemAt(indexPath: IndexPath) {
        let item = self.itemAt(indexPath: indexPath)
        self.canRemoveItem(item: item) { accept in
            if accept {
                self.list.remove(at: indexPath.item)
                self.documentColletionView.deleteItems(at: [indexPath])
                self.didRemoveItem(item: item)
            }
        }
    }
    
    // MARK: - Open methods
    open var navigationBarTitle: String {
        return "Document Grid ViewController"
    }
    open func setupNavBar() {
        self.navigationItem.title = self.navigationBarTitle
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                 target: self,
                                                                 action: #selector(DocumentGridViewController.actionAddNew))
    }
    
    open func canRemoveItem(item: DocumentGridItem, completion: @escaping ((_ accept: Bool)->())) {
        completion(true)
    }
    
    open func didRemoveItem(item: DocumentGridItem) {
        
    }
    
    open func didAddNew(item: DocumentGridItem) {
        
    }
}

// MARK: - SetupViews
extension DocumentGridViewController {
    private func setupViews() {
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
        self.setupNavBar()
        self.setupCollectionView()
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(DocumentGridViewController.longGesture(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DocumentGridViewController.longGesture(_:)))
        self.documentColletionView.addGestureRecognizer(longGesture)
        self.documentColletionView.addGestureRecognizer(tapGesture)
    }
    
    private func setupCollectionView() {
        self.view.addSubview(self.documentColletionView)
        NSLayoutConstraint.activate([
            self.documentColletionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.documentColletionView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.documentColletionView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            self.documentColletionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - Alert Actions
extension DocumentGridViewController {
    
    @objc open func openCamera(controller: DocumentGridViewController) {
        self.showUIImagePicker(sourceType: .camera,
                               allowsEditing: true,
                               delegate: self)
    }
    
    @objc open func openGalery(controller: DocumentGridViewController) {
        self.showUIImagePicker(sourceType: .photoLibrary,
                               allowsEditing: false,
                               delegate: self)
    }
    
    @objc open func openDocument(controller: DocumentGridViewController) {
        self.showFiles()
    }
}

// MARK: - UIAlert Options
extension DocumentGridViewController {
    private var alertOption: [UIAlertAction] {
        var actions: [UIAlertAction] = []
        if self.documentGridAddOptions.contains(.camera) {
            actions.append(UIAlertAction(title: "Camera",
                                         style: .default,
                                         handler: { _ in
                self.openCamera(controller: self)
            }))
        }
        if self.documentGridAddOptions.contains(.galery) {
            actions.append(UIAlertAction(title: "Fotos e Galeria",
                                         style: .default,
                                         handler: { _ in
                self.openGalery(controller: self)
            }))
        }
        if self.documentGridAddOptions.contains(.document) {
            actions.append(UIAlertAction(title: "Documentos",
                                         style: .default,
                                         handler: { _ in
                self.openDocument(controller: self)
            }))
        }
        
        actions.append(UIAlertAction(title: "Cancelar",
                                     style: .cancel, handler: nil))
        return actions
    }
    
    private func showAlertOption() {
        self.showAlert(title: nil,
                       message: nil,
                       style: .actionSheet,
                       actions: self.alertOption)
    }
}
