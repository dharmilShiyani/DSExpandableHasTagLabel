//
//  ListTCell.swift
//  DharmilIOSTestAssessment
//
//  Created by Shiyani on 02/05/24.
//

import UIKit
import DSExpandableHasTagLabel

class ListTCell: UITableViewCell {

    //MARK: - Outlet Declaration
    @IBOutlet var lblTitle: DSExpandableHasTagLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
