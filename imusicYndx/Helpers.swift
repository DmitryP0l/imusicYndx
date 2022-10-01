//
//  Helpers.swift
//  imusicYndx
//
//  Created by Dmitry P on 17.09.22.
//

import UIKit



final class CustomCollectionViewFlowLayout: UICollectionViewFlowLayout {
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
    case bensoundLifeiswonderful
    case bensoundMass
    case bensoundGlitchfidelity
    case pianomoment
    
    var trackName: String {
        switch self {
        case .bensoundLifeiswonderful:  return "1 - Life Is Wonderful (Song + Instrumental)"
        case .bensoundMass:             return "2 - Mass"
        case .bensoundGlitchfidelity:   return "3 - Glitch"
        case .pianomoment:              return "4 - Piano Moment"
            
        }
    }
    var cover: String {
        switch self {
        case .bensoundLifeiswonderful:  return "zacnelson"
        case .bensoundMass:             return "theatreofdelays"
        case .bensoundGlitchfidelity:   return "yari"
        case .pianomoment:              return "pianomoment"
            
        }
    }
    var artist: String {
        switch self {
        case .bensoundLifeiswonderful:  return "Zac Nelson"
        case .bensoundMass:             return "Theatre Of Delays"
        case .bensoundGlitchfidelity:   return "Fidelity Yari"
        case .pianomoment:              return "Benjamin Tissot"
        }
    }
    var fileName: String {
        switch self {
        case .bensoundLifeiswonderful:  return "bensound-lifeiswonderful"
        case .bensoundMass:             return "bensound-mass"
        case .bensoundGlitchfidelity:   return "bensound-glitchfidelity"
        case .pianomoment:              return "pianomoment"
        }
    }
}


