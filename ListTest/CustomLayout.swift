//
//  CustomLayout.swift
//  ListTest
//
//  Created by Артeмий Шлесберг on 08.10.2021.
//

import Foundation
import UIKit


class CustomLayout: UICollectionViewLayout {
    
    
    override init() {
        super.init()
    }
    
    let sectorWidth = UIScreen.main.bounds.width
    let sectorHeight: CGFloat = 200//UIScreen.main.bounds.height / 6 * 2
    let itemsInSector = 3

    func sectorNumber(from indexPath: IndexPath) -> Int {
        return indexPath.row / itemsInSector
    }

    func visibleIndexes(in rect: CGRect) -> [IndexPath] {
        
        let iStart: Int = Int(rect.minY / sectorHeight)
        let iEnd: Int = Int(rect.maxY / sectorHeight) + 1

        return ((iStart * 3)..<(iEnd * 3)).filter{ $0 >= 0 } .map { IndexPath(row: $0, section: 0) }

    }
//x: sectorFrame.origin.x + 10,
//y: sectorFrame.origin.y + 10,
//width: sectorWidth / 3.0 - 20,
//height: sectorHeight / 2.0 - 20)
    
    private func basicRect(for indexPath: IndexPath) -> CGRect {

        let sectorFrame = CGRect(
            x: 0,
            y: sectorHeight * CGFloat(sectorNumber(from: indexPath)),
            width: sectorWidth,
            height: sectorHeight)

        
        switch indexPath.row % 2 {
        case 0:
            return CGRect(
                x: sectorFrame.origin.x + 72,
                y: sectorFrame.origin.y + 50,
                width: 90,
                height: 90)
        case 1:
            return CGRect(
                x: sectorFrame.origin.x + 212,
                y: sectorFrame.origin.y + 10,
                width: 70,
                height: 70)
        case 2:
            return CGRect(
                x: sectorFrame.origin.x + 260,
                y: sectorFrame.origin.y + 148,
                width: 70,
                height: 70)

        default:
            return .zero
        }

    }
    var cachedAttributes: [UICollectionViewLayoutAttributes] = []
    var contentBounds: CGRect = .zero
    
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        cachedAttributes.removeAll()

        contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
            
        let count = collectionView.numberOfItems(inSection: 0)

        for i in 0..<count {
            let indexPath = IndexPath(row: i, section: 0)
            let attributeFrame = basicRect(for: indexPath)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = attributeFrame
            cachedAttributes.append(attributes)
            contentBounds = contentBounds.union(attributeFrame)
        }
        
    }


    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let indices = visibleIndexes(in: rect)
        guard !indices.isEmpty else { return nil }
        
        return Array(cachedAttributes.dropFirst(indices.first!.row).prefix(indices.count))
        
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
