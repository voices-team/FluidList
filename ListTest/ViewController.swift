//
//  ViewController.swift
//  ListTest
//
//  Created by Артeмий Шлесберг on 06.10.2021.
//

import UIKit

class ViewController: UIViewController {
    
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: CustomSpringyLayout())
    let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(CreatorCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        collectionView.backgroundColor = .black
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        updateVisibleCells()
    }
    lazy var tresholdStart: CGFloat = thresholdEnd - tresholdDiff
    var tresholdDiff: CGFloat = 50
    
    let thresholdEnd = UIScreen.main.bounds.height * 0.8

}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        (collectionView.collectionViewLayout as? CustomSpringyLayout)?.updateContentSize(for: 120)
        return 120
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CreatorCollectionViewCell
        let large = indexPath.row < 6 && indexPath.row % 3 == 0
        cell.fill(large: large, parentController: self)
//        cell.contentView.backgroundColor = .orange
//        cell.backgroundColor = .clear
//        cell.contentView.layer.cornerRadius = 20
//        cell.contentView.layer.borderColor = UIColor.white.cgColor
//        cell.contentView.layer.borderWidth = 1
//        cell.contentView.clipsToBounds = true
        return cell
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateVisibleCells()
    }
    
    func updateVisibleCells() {
        collectionView.visibleCells.forEach {
            let y = $0.frame.maxY - collectionView.contentOffset.y
            if y >= thresholdEnd {
                $0.contentView.alpha = 0.4
            } else if y > tresholdStart {
                $0.contentView.alpha = 0.4 + 0.6 * (1 - (y - tresholdStart) / tresholdDiff)
            } else {
                $0.contentView.alpha = 1
            }
        }
    }
}
