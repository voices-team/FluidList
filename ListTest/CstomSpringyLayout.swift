//
//  CstomSpringyLayout.swift
//  ListTest
//
//  Created by Артeмий Шлесберг on 08.10.2021.
//

import Foundation
import UIKit

class CustomSpringyLayout: UICollectionViewLayout {
    
    lazy var dynamicAnimator: UIDynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
    
    override init() {
        super.init()
    }
    
    private var itemsCount: Int = 0
    func updateContentSize(for count: Int) {
        itemsCount = count
        contentSize = CGSize(width: self.collectionView?.bounds.width ?? 0, height: sectorHeight * CGFloat(count) / CGFloat(itemsInSector))
    }
    
    private var contentSize: CGSize = .zero
    
    override  var collectionViewContentSize: CGSize {
        return contentSize
    }
 
    private var visibleIndexPathsSet = Set<IndexPath>()
    private var latestDelta = 0.0
    
    override func prepare() {
        super.prepare()
        
        let visibleRect = CGRect(origin: self.collectionView?.bounds.origin ?? CGPoint.zero, size: self.collectionView?.frame.size ?? CGSize.zero)//.insetBy(dx: -100, dy: -100)
        
        let itemsIndexPathsInVisibleRectSet = Set(visibleIndexes(in: visibleRect))
        print("preparing layout for rect: \(visibleRect), for \(itemsIndexPathsInVisibleRectSet.count) items")
        
        let noLongerVisibleBehaviors = self.dynamicAnimator.behaviors.filter
        { behavior in
            guard let behavior = behavior as? UIAttachmentBehavior else { return false }
            guard let attribute = behavior.items.first as? UICollectionViewLayoutAttributes else { return false }
            let currentlyVisible = itemsIndexPathsInVisibleRectSet.contains(attribute.indexPath)
            return !currentlyVisible
        }
        
        noLongerVisibleBehaviors.forEach
        { behavior in
            self.dynamicAnimator.removeBehavior(behavior)
            guard let behavior = behavior as? UIAttachmentBehavior else { return }
            guard let attribute = behavior.items.first as? UICollectionViewLayoutAttributes else { return }
            self.visibleIndexPathsSet.remove(attribute.indexPath)
        }
        
        let newlyVisibleItemsInexes = itemsIndexPathsInVisibleRectSet.filter { item in
            let currentlyVisible = self.visibleIndexPathsSet.contains(item)
            return !currentlyVisible
        }
        
        let newlyVisibleItems: [UICollectionViewLayoutAttributes] = newlyVisibleItemsInexes.map {
            let attribute = UICollectionViewLayoutAttributes(forCellWith: $0)
            attribute.frame = basicRect(for: $0)
            return attribute
        }
        
        let touchLocation = self.collectionView?.panGestureRecognizer.location(in: self.collectionView)

        
        for item in newlyVisibleItems
        {
            var center = item.center
            let springBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: center)
            
            springBehavior.length = 0.0
            springBehavior.damping = 0.8
            springBehavior.frequency = 1.0
            
            if let touchLocation = touchLocation, CGPoint.zero != touchLocation
            {
                let yDistanceFromTouch = fabs(touchLocation.y - springBehavior.anchorPoint.y)
                let xDistanceFromTouch = fabs(touchLocation.x - springBehavior.anchorPoint.x)
                let scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0
                
                if self.latestDelta < 0.0
                {
                    center.y += max(self.latestDelta, self.latestDelta * scrollResistance)
                }
                else
                {
                    center.y += min(self.latestDelta, self.latestDelta * scrollResistance)
                }
                item.center = center
            }
            self.dynamicAnimator.addBehavior(springBehavior)
            self.visibleIndexPathsSet.insert(item.indexPath)
        }
    }

//
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.dynamicAnimator.items(in: rect).compactMap { $0 as? UICollectionViewLayoutAttributes }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        self.dynamicAnimator.layoutAttributesForCell(at: indexPath)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        let scrollView = self.collectionView
        let delta = newBounds.origin.y - (scrollView?.bounds.origin.y ?? 0)
        self.latestDelta = delta
        let touchLocation = self.collectionView?.panGestureRecognizer.location(in: self.collectionView)
        
        for springBehavior in self.dynamicAnimator.behaviors
        {
            guard let springBehavior = springBehavior as? UIAttachmentBehavior, let touchLocation = touchLocation else { continue }
            let yDistanceFromTouch = fabs(touchLocation.y - springBehavior.anchorPoint.y)
            let xDistanceFromTouch = fabs(touchLocation.x - springBehavior.anchorPoint.x)
            let scrollResistance: CGFloat = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0
            
            guard let item = springBehavior.items.first as? UICollectionViewLayoutAttributes else { continue }
            var center = item.center
            if self.latestDelta < 0.0
            {
                center.y += max(self.latestDelta, self.latestDelta * scrollResistance)
            }
            else
            {
                center.y += min(self.latestDelta, self.latestDelta * scrollResistance)
            }
            item.center = center
//            print("\(item.center) \(item.indexPath)")
            self.dynamicAnimator.updateItem(usingCurrentState: item)
        }
        
        return false
    }
    
    //MARK: - Sectors
    private static let sideOffset: CGFloat = 10
    private let sectorWidth = UIScreen.main.bounds.width - sideOffset * 2
    private let sectorHeight: CGFloat = 270//UIScreen.main.bounds.height / 6 * 2
    private let itemsInSector = 3

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
        
        switch itemsCount {
        case 2:
            return basicRectForTwo(for: indexPath)
        case 3:
            return basicRectForThree(for: indexPath)
        case 4:
            return basicRectForFour(for: indexPath)
        case 5:
            return basicRectForFive(for: indexPath)
        default:
            return basicRectForMoreThanSix(for: indexPath)
        }
    }
    
    private func basicRectForTwo(for indexPath: IndexPath) -> CGRect {
        return .zero
    }
    
    private func basicRectForThree(for indexPath: IndexPath) -> CGRect {
        return .zero
    }
    
    private func basicRectForFour(for indexPath: IndexPath) -> CGRect {
        return .zero
    }
    
    private func basicRectForFive(for indexPath: IndexPath) -> CGRect {
        return .zero
    }
    
    func basicRectForMoreThanSix(for indexPath: IndexPath) -> CGRect {
        let offset = CustomSpringyLayout.sideOffset
        let sectorNumber = sectorNumber(from: indexPath)
        let sectorFrame = CGRect(
            x: offset,
            y: (sectorHeight + offset) * CGFloat(sectorNumber),
            width: sectorWidth,
            height: sectorHeight)

        let isSectorEven = sectorNumber % 2 == 0
        switch indexPath.row % 3 {
        case 0:
            let originX: CGFloat = isSectorEven ? 0 : 140
            return CGRect(
                x: sectorFrame.origin.x + originX,
                y: sectorFrame.origin.y + 50,
                width: 215,
                height: 163)
        case 1:
            let originX: CGFloat = isSectorEven ? 177 : 37
            return CGRect(
                x: sectorFrame.origin.x + originX,
                y: sectorFrame.origin.y + 0,
                width: 140,
                height: 121)
        case 2:
            let originX: CGFloat = isSectorEven ? 215 : 0
            return CGRect(
                x: sectorFrame.origin.x + originX,
                y: sectorFrame.origin.y + 148,
                width: 140,
                height: 121)

        default:
            return .zero
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
