//
//  InformationTableViewCell.swift
//  Weather
//
//  Created by Yury Radetsky on 15.04.2021.
//

import UIKit

struct InformationTableViewCellViewModel {
    let informationLabelString: String?
}

final class InformationTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var informationLabel: UILabel!
    
    private var weatherModel: WeatherModel?
    static let identifier = "InformationTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "InformationTableViewCell",
                     bundle: nil)
    }
    
    func configure(model: WeatherModel) {
        self.weatherModel = model
    }
    
    func configureTableViewCellViewModelFor(_ index: Int) -> InformationTableViewCellViewModel {
        var informationLabelString: String?
        if let weatherMode = weatherModel {
            informationLabelString = "Today: \(weatherMode.current.weather[0].descriptionWeather.firstCapitalized). The hight will be \(String(format: "%.f", weatherMode.daily[0].temp.night))°. "
        }
        return InformationTableViewCellViewModel(informationLabelString: informationLabelString)
    }
    
    func setupCell(_ viewModel: InformationTableViewCellViewModel) {
        informationLabel.text = viewModel.informationLabelString
    }
    
}
