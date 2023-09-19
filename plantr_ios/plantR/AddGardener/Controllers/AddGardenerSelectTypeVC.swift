//
//  AddGardenerSelectTypeVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 25/05/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit


class AddGardenerSelectType: UIViewController {
    
    let gardenerType: [String] = [GardenerType.Classic, GardenerType.Agrove]
    let typeGardener = [
        GardenerTypeStruct(type: GardenerType.Classic, title: NSLocalizedString("classic_garden", comment: "classic garden"), desc: NSLocalizedString("in_a_square_in_a_pot_or", comment: "In a square, in a pot or in a window box"), image: "potagers_classiques"),
        GardenerTypeStruct(type: GardenerType.Agrove, title: NSLocalizedString("agrove_garden", comment: "agrove garden"), desc: NSLocalizedString("connected_garden_kits", comment: "connected_garden_kits"), image: "kits_agrove")
    ]

    @IBOutlet var lTitle: UILabel!
    @IBOutlet var tvType: UITableView!
    @IBOutlet var vContainer: CornerRaduisV!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurredView.frame = self.view.bounds
        self.view.addSubview(blurredView)
        self.view.bringSubviewToFront(vContainer)

        self.tvType.delegate = self
        self.tvType.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func ibBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension AddGardenerSelectType : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.typeGardener.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addGardenerSelectType", for: indexPath) as! AddGardenerTypeCell
    
        let type = self.typeGardener[indexPath.row].type
        switch type {
        case GardenerType.Classic:
            cell.type = GardenerType.Classic
        case GardenerType.Agrove:
            cell.type = GardenerType.Agrove
        default:
            cell.type = GardenerType.Classic
        }
        cell.delegate = self
        cell.ivType.image = UIImage(named: self.typeGardener[indexPath.row].image)
        cell.lTitleCard.text = self.typeGardener[indexPath.row].title
        cell.lDescription.text = self.typeGardener[indexPath.row].desc
        
        return cell
    }
}

extension AddGardenerSelectType: AddGardenerTypeDelegate {
    func didSelectType(type: String) {
        print("didSelectType => \(type)")
        switch type {
        case GardenerType.Classic:
            AddGardenerService.shared.kitAgrove = false
            self.performSegue(withIdentifier: "goToTypeSelecting", sender: nil)
        case GardenerType.Agrove:
            AddGardenerService.shared.kitAgrove = true
            self.performSegue(withIdentifier: "goToSelectKit", sender: nil)
        default:
            AddGardenerService.shared.kitAgrove = false
            self.performSegue(withIdentifier: "goToTypeSelecting", sender: nil)
        }
    }
}
