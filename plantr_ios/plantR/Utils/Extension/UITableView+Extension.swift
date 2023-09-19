//
//  UITableView+Extension.swift
//  plantR_ios
//
//  Created by Boris Roussel on 11/05/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit

extension UITableView {
 
    // CODE MAGIC --> AUTOMATIC CALCUL HEADER HEIGHT
    //Variable-height UITableView tableHeaderView with autolayout
    func layoutTableHeaderView() {
        guard let headerView = self.tableHeaderView else { return }
        headerView.translatesAutoresizingMaskIntoConstraints = false
         
        let headerWidth = headerView.bounds.size.width;
            let temporaryWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[headerView(width)]", options: NSLayoutConstraint.FormatOptions(rawValue: UInt(0)), metrics: ["width": headerWidth], views: ["headerView": headerView])
         
        headerView.addConstraints(temporaryWidthConstraints)
         
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
         
        let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = headerSize.height
        var frame = headerView.frame
         
        frame.size.height = height
        headerView.frame = frame
         
        self.tableHeaderView = headerView
         
        headerView.removeConstraints(temporaryWidthConstraints)
        headerView.translatesAutoresizingMaskIntoConstraints = true
    }
}
