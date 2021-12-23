//
//  DocumentCollectionViewCell.swift
//  CompraFacil_iOS
//
//  Created by Rubens Machion on 22/12/21.
//

import UIKit

final public class DocumentCollectionViewCell: UICollectionViewCell {

    public static let identifier = String(describing: DocumentCollectionViewCell.self)
    
    internal lazy var buttonDelete: UIButton = {
        if #available(iOS 13.0, *) {
            $0.backgroundColor = .systemBackground
        } else {
            $0.backgroundColor = .white
        }
        $0.tintColor = .gray
        $0.layer.cornerRadius = 15.0
        $0.setImage(UIImage(named: "closeButton",
                            in: Bundle.module,
                            compatibleWith: nil),
                    for: .normal)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(DocumentCollectionViewCell.deleteItem),
                     for: .touchUpInside)
        return $0
    }(UIButton())
    
    internal lazy var thumbImage: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        return $0
    }(UIImageView())
    
    public var willRemove: ((_ cell: DocumentCollectionViewCell)->())? = nil
    
    // MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    public func setup(image: UIImage) {
        self.thumbImage.image = image
    }
    
    @objc private func deleteItem() {
        self.willRemove?(self)
    }
    
    public func setDelete(enable: Bool) {
        self.buttonDelete.isHidden = !enable
    }
}

// MARK: - DocumentCollectionViewCell
extension DocumentCollectionViewCell {
    private func setupViews() {
        self.contentView.backgroundColor = .groupTableViewBackground
        self.setupThumb()
        self.setupButtonDelete()
    }
    
    private func setupThumb() {
        self.contentView.addSubview(self.thumbImage)
        
        NSLayoutConstraint.activate([
            self.thumbImage.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.thumbImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.thumbImage.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.thumbImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    private func setupButtonDelete() {
        self.contentView.addSubview(self.buttonDelete)
        NSLayoutConstraint.activate([
            self.buttonDelete.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                                   constant: -10.0),
            self.buttonDelete.rightAnchor.constraint(equalTo: self.contentView.rightAnchor,
                                                     constant: 8.0),
            self.buttonDelete.widthAnchor.constraint(equalToConstant: 29.0),
            self.buttonDelete.heightAnchor.constraint(equalToConstant: 29.0)
        ])
    }
}
