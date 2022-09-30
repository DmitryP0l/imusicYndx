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
            labelNoTrack.text = model.labelNum
        }
    }

    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    let labelNoTrack: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 50.0)
        return label
    }()
    
    let labelNoIndexPath: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30.0)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(imageView)
        contentView.addSubview(labelNoTrack)
        contentView.addSubview(labelNoIndexPath)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
        imageView.layer.borderWidth = 6.0
        
        labelNoTrack.translatesAutoresizingMaskIntoConstraints = false
        labelNoTrack.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10).isActive = true
        labelNoTrack.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        
        labelNoIndexPath.translatesAutoresizingMaskIntoConstraints = false
        labelNoIndexPath.topAnchor.constraint(equalTo: labelNoTrack.bottomAnchor, constant: 5).isActive = true
        labelNoIndexPath.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



