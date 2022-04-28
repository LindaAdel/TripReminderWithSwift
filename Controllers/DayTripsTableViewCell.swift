//
//  DayTripsTableViewCell.swift
//  TripReminder
//
//  Created by Linda adel on 12/21/21.
//

import UIKit

class DayTripsTableViewCell: UITableViewCell {
    //MARK: IBOutlest
    
    @IBOutlet weak var tripNameLabel: UILabel!
    
    @IBOutlet weak var startTripButton: UIButton!
    
    @IBOutlet weak var tripNameTitleLabel: UILabel!
    
    
    @IBOutlet weak var cancelLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cancelLabel.isHidden = true
        startTripButton.isHidden = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
