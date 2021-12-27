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
    
    public var image: UIImage? = nil
    public var pdfURL: URL? = nil
    public var docType: DocType!
    
    public init(image: UIImage) {
        self.image = image
        self.docType = .image
    }
    
    public init(pdf url: URL) {
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
        cell.willRemove = { [weak self] c in
            guard let index = collectionView.indexPath(for: c) else {
                return
            }
            self?.removeItemAt(indexPath: index)
        }
        if collectionView.allowsMultipleSelection {
            cell.shake()
        } else {
            cell.stopShake()
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
        
        let size = self.bounds.size
        if #available(iOS 13.0, *) {
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
    
//    private func pdfThumbnail(url: URL, width: CGFloat = 240) -> UIImage? {
//        guard let data = try? Data(contentsOf: url),
//              let page = PDFDocument(data: data)?.page(at: 0) else {
//                  return nil
//              }
//
//        let pageSize = page.bounds(for: .mediaBox)
//        let pdfScale = width / pageSize.width
//
//        // Apply if you're displaying the thumbnail on screen
//        let scale = UIScreen.main.scale * pdfScale
//        let screenSize = CGSize(width: pageSize.width * scale,
//                                height: pageSize.height * scale)
//
//        return page.thumbnail(of: screenSize, for: .mediaBox)
//    }
}

