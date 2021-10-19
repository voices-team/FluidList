//
//  CollectionViewSpringyLayout.swift
//  ListTest
//
//  Created by Артeмий Шлесберг on 07.10.2021.
//

import Foundation
import UIKit

class SpringyLayout: UICollectionViewFlowLayout {
    
    lazy var dynamicAnimator: UIDynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
    
    override init() {
        
        super.init()
        
        self.minimumInteritemSpacing = 50;
        self.minimumLineSpacing = 30;
        self.itemSize = CGSize(width: 60, height: 60);
        self.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10);
        
    }
 
    var visibleIndexPathsSet = Set<IndexPath>()
    var latestDelta = 0.0
    
    override func prepare() {
        super.prepare()
        let visibleRect = CGRect(origin: self.collectionView?.bounds.origin ?? CGPoint.zero, size: self.collectionView?.frame.size ?? CGSize.zero).insetBy(dx: -100, dy: -100)
        
        let itemsInVisibleRectArray = super.layoutAttributesForElements(in: visibleRect) ?? []
        let itemsIndexPathsInVisibleRectSet =
            Set(itemsInVisibleRectArray.map{ $0.indexPath })
        
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
        
        let newlyVisibleItems = itemsInVisibleRectArray.filter
        { item in
            let currentlyVisible = self.visibleIndexPathsSet.contains(item.indexPath)
            return !currentlyVisible
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
            print("\(item.center) \(item.indexPath)")
            self.dynamicAnimator.updateItem(usingCurrentState: item)
        }
        
        return false
    }


    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
