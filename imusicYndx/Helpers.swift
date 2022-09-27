//
//  Helpers.swift
//  imusicYndx
//
//  Created by Dmitry P on 17.09.22.
//

import UIKit



class CustomCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        scrollDirection = .horizontal
        minimumLineSpacing = 0.0
        itemSize = CGSize(width: UIScreen.main.bounds.width/3*2, height: UIScreen.main.bounds.width/3*2)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView!.contentInset.left
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView!.bounds.size.width, height: collectionView!.bounds.size.height)
        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        })
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}



enum Track: CaseIterable {
    case blackbirdLonelyBird
    case blackbirdTrapped
    case black
    case white
    
    var trackName: String {
        switch self {
        case .blackbirdLonelyBird:  return "1"
        case .blackbirdTrapped:     return "2"
        case .black:                return "3"
        case .white:                return "4"
                
        }
    }
    var cover: String {
        switch self {
        case .blackbirdLonelyBird:  return "pic1"
        case .blackbirdTrapped:     return "pic5"
        case .black:                return "pic1"
        case .white:                return "pic5"
                
        }
    }
    var artist: String {
        switch self {
        case .blackbirdLonelyBird:  return "blackbird"
        case .blackbirdTrapped:     return "blackbird"
        case .white:                return "blackbird"
        case .black:                return "blackbird"
        }
    }
    var fileName: String {
        switch self {
        case .blackbirdLonelyBird:  return "blackbird-lonely-bird"
        case .blackbirdTrapped:     return "blackbird-trapped"
        case .black:                return "blackbird-trapped"
        case .white:                return "blackbird-lonely-bird"
        }
    }
}


