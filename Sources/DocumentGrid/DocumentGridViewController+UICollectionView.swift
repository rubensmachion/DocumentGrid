//
//  DocumentGridViewController+UICollectionView.swift
//  CompraFacil_iOS
//
//  Created by Rubens Machion on 22/12/21.
//

import UIKit

public struct DocumentGridItem {
    public let image: UIImage?
    
    public init(image: UIImage) {
        self.image = image
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
        if #available(iOS 15.0, *) {
            self.thumbImage.image = item.image?.preparingThumbnail(of: CGSize(width: (item.image?.size.width ?? 1.0) * 0.3,
                                                                              height: (item.image?.size.height ?? 1.0) * 0.3))
        } else {
            self.thumbImage.image = item.image
        }
    }
}

// MARK: - UIView Shake
public extension UIView {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 0.07
        animation.repeatCount = HUGE
        animation.autoreverses = true
        
        let startAngle = (-2) * Double.pi/180.0;
        let stopAngle = -startAngle;
        
        animation.fromValue = NSNumber(value: startAngle)
        animation.toValue =  NSNumber(value: stopAngle)
        
        self.layer.add(animation, forKey: "quivering")
    }
    
    func stopShake() {
        let layer = self.layer;
        layer.removeAnimation(forKey: "quivering")
    }
}
