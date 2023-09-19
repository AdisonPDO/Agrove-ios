//
//  InformationPlantsHeaderView.swift
//  plantR_ios
//
//  Created by Mathieu Rabissoni on 03/05/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

class InformationPlantsHeaderView: UIView {

    @IBOutlet var mainView: UIView!

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var seedlingArrayLabel: [UILabel]!
    @IBOutlet var harvestArrayLabel: [UILabel]!
    @IBOutlet weak var exhibitionStackView: UIStackView!
    @IBOutlet weak var waterStackView: UIStackView!
    @IBOutlet weak var freezeStackView: UIStackView!
    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet var semisLabel: UILabel!
    @IBOutlet var recoltLabel: UILabel!
    @IBOutlet var caracLabel: UILabel!
    @IBOutlet var resLabel: UILabel!
    @IBOutlet var heighLabel: UILabel!
    @IBOutlet var waterLabel: UILabel!
    @IBOutlet var expoLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        descriptionLabel.adjustsFontSizeToFitWidth = true
        setupTrad()
    }
    
    func setupTrad(){
        self.semisLabel.text = NSLocalizedString("semis", comment: "semis")
        self.recoltLabel.text = NSLocalizedString("recolt", comment: "recolt")
        self.caracLabel.text = NSLocalizedString("carac", comment: "carac")
        self.expoLabel.text = NSLocalizedString("expo", comment: "expo")
        self.resLabel.text = NSLocalizedString("res", comment: "res")
        self.waterLabel.text = NSLocalizedString("water", comment: "water")
        self.heighLabel.text = NSLocalizedString("height", comment: "height")
    }
    func formatteStackView(stackView: UIStackView, level: Int) {
        switch level {
        case 1:
            stackView.arrangedSubviews[2].isHidden = true
            stackView.arrangedSubviews[1].isHidden = true
            return
        case 2:
            stackView.arrangedSubviews[2].isHidden = true
            return
        default:
            return
        }
    }
    
    func setAllHeaderInformation(plantModel: InfosPlants) {
        self.descriptionLabel.text = plantModel.infoPlant.description
        self.heightLabel.text = plantModel.infoPlant.characteristic.height
        formatteStackView(stackView: self.exhibitionStackView, level: plantModel.infoPlant.characteristic.exhibition)
        formatteStackView(stackView: self.waterStackView, level: plantModel.infoPlant.characteristic.water)
        formatteStackView(stackView: self.freezeStackView, level: plantModel.infoPlant.characteristic.rusticite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("InformationPlantsHeaderView", owner: self, options: nil)
        addSubview(mainView)
        mainView.frame = self.bounds
        mainView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
}
