//
//  DocumentGridViewController+UICollectionView.swift
//  CompraFacil_iOS
//
//  Created by Rubens Machion on 22/12/21.
//

import Foundation
import UIKit
import QuickLook

// MARK: - Singleton List
public struct DocumentGridItems {
    public static var shared = DocumentGridItems()
    
    public var list: [DocumentGridItem] = []
    
    private init() {}
    
    public mutating func clearList() {
        self.list.removeAll()
    }
}

// MARK: - DocumentGridItem
public class DocumentGridItem: NSObject {
    public enum DocType {
        case pdf
        case image
        
        public var icon: UIImage? {
            switch self {
            case .pdf:
                return UIImage.image(named: "ic_pdf")
            case .image:
                return UIImage.image(named: "ic_jpg")
            }
        }
        
        public var localized: String {
            switch self {
            case .pdf:
                return "Arquivo PDF"
            case .image:
                return "Imagem"
            }
        }
    }
    
    public var id: String!
    public var image: UIImage? = nil
    public var url: URL? = nil
    public var docType: DocType!
    public var progress: Double = 0.0
    public var downloaded: Bool = false
    public var data: Data? = nil
    
    public init(image: UIImage) {
        self.id = UUID().uuidString
        self.image = image
        self.data = image.jpegData(compressionQuality: 0.7)
        self.docType = .image
    }
    
    public init(pdf url: URL) {
        self.id = UUID().uuidString
        self.url = url
        self.docType = .pdf
    }
    
    public init(id: String? = nil, document: Document) {
        self.id = (id?.isEmpty ?? true) ? UUID().uuidString : id
        self.data = document.data
        self.url = document.fileURL
        if document.fileType?.contains("pdf") ?? false {
            self.docType = .pdf
        } else if document.fileType?.contains("png") ?? false ||
                    document.fileType?.contains("jpg") ?? false ||
                    document.fileType?.contains("jpeg") ?? false {
            self.docType = .image
        } else {
            self.docType = .none
        }
    }
}

// MARK: - QuickLook
extension DocumentGridItem: QLPreviewItem {
    public var previewItemURL: URL? {
        return self.url
    }
    
    public var previewItemTitle: String? {
        return self.docType.localized
    }
}

// MARK: - File Manager: DocumentGridItem
extension DocumentGridItem {
    
    func downloadFile(completion: @escaping (_ success: Bool)->()) {
        guard let url = self.url else { return }
        let urlSession = URLSession(configuration: .default,
                                    delegate: nil,
                                    delegateQueue: OperationQueue())
        let request = URLRequest(url: url)
        urlSession.downloadTask(with: request) { location, responseURL, error in
            if error == nil {
                let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
                try? FileManager.default.removeItem(at: destinationURL)
                do {
                    try FileManager.default.copyItem(at: location!, to: destinationURL)
                    self.url = destinationURL
                    self.data = try Data(contentsOf: destinationURL)
                    self.downloaded = true
                    completion(true)
                } catch let error {
                    print("Copy Error: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }.resume()
    }
}

// MARK: - DocumentGridViewController+UICollectionViewDataSource
extension DocumentGridViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems()
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = self.itemAt(indexPath: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionViewCell.identifier,
                                                      for: indexPath) as! DocumentCollectionViewCell
        cell.setup(item: item)
        if canAddNewFiles {
            cell.setDelete(enable: collectionView.allowsMultipleSelection)
            if collectionView.allowsMultipleSelection {
                cell.shake()
            } else {
                cell.stopShake()
            }
        }
        cell.willRemove = { [weak self] c in
            guard let index = collectionView.indexPath(for: c) else {
                return
            }
            self?.removeItemAt(indexPath: index)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension DocumentGridViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.openPreviewAt(index: indexPath)
    }
}

// MARK: - DocumentCollectionViewCell+DocumentGridItem
extension DocumentCollectionViewCell {
    
    func setup(item: DocumentGridItem) {
        
        self.progressValue = item.progress
        if item.data == nil {
            self.activityIndicator.startAnimating()
            item.downloadFile { success in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    if success {
                        self.setup(item: item)
                    } else {
                        self.thumbImage.contentMode = .center
                        self.thumbImage.image = item.docType.icon
                    }
                }
            }
        } else {
            let size = self.bounds.size
            if #available(iOS 13.0, *), let url = item.url{
                self.generateThumbnail(url: url,
                                       size: size,
                                       scale: UIScreen.main.scale) { image in
                    self.thumbImage.contentMode = .scaleAspectFit
                    self.thumbImage.image = image
                }
            } else {
                switch item.docType {
                case .image:
                    self.thumbImage.contentMode = .scaleAspectFit
                    if let data = item.data, let image = UIImage(data: data) {
                        if #available(iOS 15.0, *) {
                            self.thumbImage.image = image.preparingThumbnail(of: size)
                        } else {
                            self.thumbImage.image = image
                        }
                    }
                    break
                default:
                    self.thumbImage.image = item.docType.icon
                    break
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func generateThumbnail(url: URL,
                                   size: CGSize,
                                   scale: CGFloat,
                                   completion: @escaping (_ image: UIImage?)->()) {
        
        let request = QLThumbnailGenerator.Request(fileAt: url,
                                                   size: size,
                                                   scale: scale,
                                                   representationTypes: .all)
        
        let generator = QLThumbnailGenerator.shared
        generator.generateBestRepresentation(for: request) { thumbnail, error in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil {
                    completion(nil)
                } else {
                    completion(thumbnail?.uiImage)
                }
            }
        }
    }
}
