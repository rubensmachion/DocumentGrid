//
//  DocumentGridViewController+UICollectionView.swift
//  CompraFacil_iOS
//
//  Created by Rubens Machion on 22/12/21.
//

import Foundation
import UIKit
import QuickLook

public struct DocumentGridItem {
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
    }
    
    public var id: String!
    public var image: UIImage? = nil
    public var url: URL? = nil
    public var docType: DocType!
    public var progress: Double = 0.0
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
    
    public init(document: Document) {
        self.id = UUID().uuidString
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

extension Document {
    
}

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
        cell.setDelete(enable: collectionView.allowsMultipleSelection)
        if collectionView.allowsMultipleSelection {
            cell.shake()
        } else {
            cell.stopShake()
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
    
}

// MARK: - DocumentCollectionViewCell+DocumentGridItem
extension DocumentCollectionViewCell {
    
    func setup(item: DocumentGridItem) {
        
        self.progressValue = item.progress
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
