//
//  HourlyCollectionViewCell.swift
//  Weather
//
//  Created by Yury Radetsky on 13.04.2021.
//

import UIKit

struct HourlyCollectionViewCellViewModel {
    let tempLabelString: String?
    let timeLabelString: String?
    let humidityLabelString: String?
    let iconImage: UIImage?
    let urlString: String?
}

final class HourlyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var tempLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    static let identifier = "HourlyCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "HourlyCollectionViewCell",
                     bundle: nil)
    }
    
    func setupCell(_ viewModel: HourlyCollectionViewCellViewModel) {
        if viewModel.timeLabelString == "Now" {
            timeLabel.text = "Now"
            timeLabel.font = UIFont.boldSystemFont(ofSize: 17)
            tempLabel.text = viewModel.tempLabelString
            tempLabel.font = UIFont.boldSystemFont(ofSize: 17)
        } else {
            timeLabel.text = viewModel.timeLabelString
            tempLabel.text = viewModel.tempLabelString
        }

        if viewModel.iconImage != nil {
            iconImageView.image = viewModel.iconImage
        } else {
            iconImageView.downloaded(from: viewModel.urlString ?? "")
        }
        
        humidityLabel.text = viewModel.humidityLabelString
    }
    
}
