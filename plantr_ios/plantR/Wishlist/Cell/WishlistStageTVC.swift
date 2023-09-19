//
//  WishlistStageTVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 05/03/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit

protocol WishlistStageCellDelegate: class {
    func didSelectButtonAt(key: String)
}

class WishlistStageCell: UITableViewCell {
    
    
    @IBOutlet weak var stageIv: UIImageView!
    weak var delegate: WishlistStageCellDelegate?
    
    var stage: Int?
    @IBOutlet weak var plantOneIV: CIRoundedImageView!
    @IBOutlet var vOne: UIView!
    @IBOutlet weak var plantTwoIV: CIRoundedImageView!
    @IBOutlet var vTwo: UIView!
    @IBOutlet weak var plantThreeIV: CIRoundedImageView!
    @IBOutlet var vThree: UIView!
    @IBOutlet weak var plantFourIV: CIRoundedImageView!
    @IBOutlet var vFour: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        vOne.isUserInteractionEnabled = true
        vTwo.isUserInteractionEnabled = true
        vThree.isUserInteractionEnabled = true
        vFour.isUserInteractionEnabled = true
        
        let tapGestureOne = UITapGestureRecognizer(target: self, action: #selector(WishlistStageCell.plantOneIVTapped(gesture:)))
        let tapGestureTwo = UITapGestureRecognizer(target: self, action: #selector(WishlistStageCell.plantTwoIVTapped(gesture:)))
        let tapGestureThree = UITapGestureRecognizer(target: self, action: #selector(WishlistStageCell.plantThreeIVTapped(gesture:)))
        let tapGestureFour = UITapGestureRecognizer(target: self, action: #selector(WishlistStageCell.plantFourIVTapped(gesture:)))


        vOne.addGestureRecognizer(tapGestureOne)
        vTwo.addGestureRecognizer(tapGestureTwo)
        vThree.addGestureRecognizer(tapGestureThree)
        vFour.addGestureRecognizer(tapGestureFour)
    }
    @objc func plantOneIVTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        print("plantOneIVTapped Tapped")
        if (gesture.view) != nil, let stage = stage {
            print("plantOneIVTapped Tapped")
            delegate?.didSelectButtonAt(key: "\(stage)-0")
        }
    }
    @objc func plantTwoIVTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        print("plantTwoIVTapped Tapped")
        if (gesture.view) != nil, let stage = stage {
            print("plantTwoIVTapped Tapped")
            delegate?.didSelectButtonAt(key: "\(stage)-1")
        }
    }
    
    @objc func plantThreeIVTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        print("plantThreeIVTapped Tapped")
        if (gesture.view) != nil, let stage = stage {
            print("plantThreeIVTapped Tapped")
            delegate?.didSelectButtonAt(key: "\(stage)-2")
        }
    }
    
    @objc func plantFourIVTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        print("plantFourIVTapped Tapped")
        if (gesture.view) != nil, let stage = stage {
            print("plantFourIVTapped Tapped")
            delegate?.didSelectButtonAt(key: "\(stage)-3")
        }
    }
}
