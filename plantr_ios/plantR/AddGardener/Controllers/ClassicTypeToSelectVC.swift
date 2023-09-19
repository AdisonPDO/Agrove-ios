//
//  ClassicTypeToSelectVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 25/05/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit

class TypeSelectVC: UIViewController {
    
    @IBOutlet var svSelectType: UITableView!
    @IBOutlet var vContainer: CornerRaduisV!
    
    let list = [
        true: [
            SelectingTypeStruct(type: GardenerType.Pot, image: "type_pot", text: NSLocalizedString("pot", comment: "Pot")),
            SelectingTypeStruct(type: GardenerType.Jardinière, image: "type_jardinière", text: NSLocalizedString("planter", comment: "planter")),
            SelectingTypeStruct(type: GardenerType.Carre, image: "type_carre", text: NSLocalizedString("vegetable_patch", comment: "vegetable patch"))
        ],
        false: [
            SelectingTypeStruct(type: GardenerType.Carre, image: "type_carre", text: NSLocalizedString("vegetable_patch", comment: "vegetable patch")),
            SelectingTypeStruct(type: GardenerType.Pot, image: "type_pot", text: NSLocalizedString("pot", comment: "pot")),
            SelectingTypeStruct(type: GardenerType.Jardinière, image: "type_jardinière", text: NSLocalizedString("planter", comment: "planter"))
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurredView.frame = self.view.bounds
        self.view.addSubview(blurredView)
        self.view.bringSubviewToFront(vContainer)

        self.svSelectType.delegate = self
        self.svSelectType.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    fileprivate func getType() -> [SelectingTypeStruct] {
        return self.list[AddGardenerService.shared.kitAgrove]!
    }
    
    @IBAction func ibBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension TypeSelectVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if AddGardenerService.shared.kitAgrove {
            return self.list[true]!.count
        } else {
            return self.list[false]!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectingTypeCell", for: indexPath) as! SelectingTypeCell
        let type = self.getType()[indexPath.row]
        cell.ivImage.image = UIImage(named: type.image)
        cell.lType.text = type.text
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("TABLEVIEW => \(self.list[AddGardenerService.shared.kitAgrove]![indexPath.row].type)")
        AddGardenerService.shared.selectingTypeStruct = self.list[AddGardenerService.shared.kitAgrove]![indexPath.row]
            self.performSegue(withIdentifier: "goToSizeType", sender: nil)
    }
}
