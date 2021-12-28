//
//  DocumentCollectionViewCell.swift
//  CompraFacil_iOS
//
//  Created by Rubens Machion on 22/12/21.
//

import UIKit
import PDFKit

final public class DocumentCollectionViewCell: UICollectionViewCell {

    public static let identifier = String(describing: DocumentCollectionViewCell.self)
    
    internal lazy var circularProgress: CircularProgressView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.trackLineWidth = 4.0
        $0.trackTintColor = UIColor.lightGray
        $0.progressTintColor = self.tintColor
        $0.roundedProgressLineCap = true
        $0.isHidden = true
        return $0
    }(CircularProgressView(frame: .zero))
    
    internal lazy var buttonDelete: UIButton = {
        if #available(iOS 13.0, *) {
            $0.backgroundColor = .systemBackground
        } else {
            $0.backgroundColor = .white
        }
        $0.tintColor = .gray
        $0.layer.cornerRadius = 18.0
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
    public var progressValue: Double! = 0.0 {
        didSet {
            self.circularProgress.progress = Float(self.progressValue)
            if self.progressValue > 0.0 && self.progressValue < 1.0 {
                self.circularProgress.isHidden = false
                self.thumbImage.alpha = 0.5
            } else {
                self.circularProgress.isHidden = true
                self.thumbImage.alpha = 1.0
            }
        }
    }
    
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
        if (self.progressValue == 0.0 || self.progressValue >= 1.0) {
            self.buttonDelete.isHidden = !enable
        } else {
            self.buttonDelete.isHidden = true
        }
    }
}

// MARK: - DocumentCollectionViewCell
extension DocumentCollectionViewCell {
    private func setupViews() {
        self.setupThumb()
        self.setupButtonDelete()
        self.setupCircularProgress()
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
    
    private func setupCircularProgress() {
        self.contentView.addSubview(self.circularProgress)
        
        NSLayoutConstraint.activate([
            self.circularProgress.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.circularProgress.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.circularProgress.widthAnchor.constraint(equalToConstant: 36.0),
            self.circularProgress.heightAnchor.constraint(equalToConstant: 36.0)
        ])
    }
}
