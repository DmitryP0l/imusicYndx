//
//  CollectionViewCell.swift
//  imusicYndx
//
//  Created by Dmitry P on 5.09.22.


import UIKit

final class CollectionViewCellTrack: UICollectionViewCell {
    
    static let identifier = "CollectionViewCellTrack"
    
    var model: CellModel? {
        didSet {
            guard let model = model else { return }
            let image = UIImage(named: model.imageName ?? "pianokeys")
            let color = image?.averageColor?.cgColor
            imageView.image = image
            imageView.layer.borderColor = color?.copy(alpha: 0.3)
        }
    }

    let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
        imageView.layer.borderWidth = 6.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



