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
    public var pdfURL: URL? = nil
    public var docType: DocType!
    public var progress: Double = 0.0
    
    public init(image: UIImage) {
        self.id = UUID().uuidString
        self.image = image
        self.docType = .image
    }
    
    public init(pdf url: URL) {
        self.id = UUID().uuidString
        self.pdfURL = url
        self.docType = .pdf
    }
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
        if #available(iOS 13.0, *), item.docType != .image {
            guard let url = item.pdfURL else { return }
            self.generateThumbnail(url: url,
                                   size: size,
                                   scale: UIScreen.main.scale) { image in
                self.thumbImage.contentMode = .scaleAspectFit
                self.thumbImage.image = image
            }
        } else {
            switch item.docType {
            case .image:
                self.thumbImage.contentMode = .scaleAspectFill
                if #available(iOS 15.0, *) {
                    self.thumbImage.image = item.image?.preparingThumbnail(of: size)
                } else {
                    self.thumbImage.image = item.image
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
