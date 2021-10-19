//
//  CreatorCollectionViewCell.swift
//  ListTest
//
//  Created by Артeмий Шлесберг on 19.10.2021.
//

import Foundation
import UIKit
import SwiftUI
class CreatorCollectionViewCell: UICollectionViewCell {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private var creatorViewController: UIHostingController<CreatorCellView>?

    private func setup() {
        backgroundColor = .clear
        return
    }

//    private var cancellables = Set<AnyCancellable>()

    func fill(
//        _ event: RoomEvent,
//              isCreator: Bool,
//              isFirstCell: Bool,
//              _ eventsCoordinator: RoomEventsCoordinator,
//              onClickBlock: @escaping ((ClickEvent) -> Void),
        large: Bool,
        parentController: UIViewController) {
        var model = CratorCellModel() //(event: event, coordinator: eventsCoordinator)
        model.large = large
        if let controller = creatorViewController {
            controller.rootView = CreatorCellView(model: model)
        } else {
            creatorViewController = UIHostingController<CreatorCellView>(rootView: CreatorCellView(model: model))
            contentView.addConstraintedSubview(creatorViewController!.view)
            creatorViewController!.view.backgroundColor = .clear
        }

        creatorViewController?.view.invalidateIntrinsicContentSize()

        let requiresControllerMove = creatorViewController?.parent != parentController
        if requiresControllerMove {
            // remove old parent if exists
            removeHostingControllerFromParent()
            parentController.addChild(creatorViewController!)
        }

        if requiresControllerMove {
            creatorViewController?.didMove(toParent: parentController)
        }

        contentView.addConstraintedSubview(creatorViewController!.view)
        contentView.layoutIfNeeded()

        return
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        creatorViewController?.view.removeFromSuperview()
    }

    private func removeHostingControllerFromParent() {
        creatorViewController?.willMove(toParent: nil)
        creatorViewController?.view.removeFromSuperview()
        creatorViewController?.removeFromParent()
    }

    deinit {
        removeHostingControllerFromParent()
    }
}


extension UIView {
    func addConstraintedSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    }
}
