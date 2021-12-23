//
//  DocumentCollectionView.swift
//  CompraFacil_iOS
//
//  Created by Rubens Machion on 22/12/21.
//

import UIKit

open class DocumentCollectionView: UICollectionView {
    
    override init(frame: CGRect,
                  collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
