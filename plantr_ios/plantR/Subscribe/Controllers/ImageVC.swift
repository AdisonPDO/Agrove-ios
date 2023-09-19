//
//  ImageVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 14/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

class ImageVC: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }

}
