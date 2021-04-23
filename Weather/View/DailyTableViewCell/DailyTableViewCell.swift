//
//  DescriptionTableViewCell.swift
//  Weather
//
//  Created by Yury Radetsky on 13.04.2021.
//

import UIKit

struct DailyTableViewCellViewModel {
    let dayLabelString: String?
    let highTempLabelString: String?
    let lowTempLabelString: String?
    let humidityLabelString: String?
    let iconImage: UIImage?
    let urlString: String?
    
}

final class DailyTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var highTempLabel: UILabel!
    @IBOutlet private weak var lowTempLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    private var weatherModel: WeatherModel?
    static let identifier = "DailyTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "DailyTableViewCell",
                     bundle: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
    }
    
    func configure(model: WeatherModel) {
        self.weatherModel = model
    }
    
    func configureTableViewCellViewModelFor(_ index: Int) -> DailyTableViewCellViewModel {
        var dayLabelString: String?
        var highTempLabelString: String?
        var lowTempLabelString: String?
        var humidityLabelString: String?
        var iconImage: UIImage?
        var urlString: String?
        
        if let weatherModel =  weatherModel {
            let dailyModel = weatherModel.daily[index + 1]
            dayLabelString = Date(timeIntervalSince1970: Double(dailyModel.dt)).getDayForDate()
            highTempLabelString = String(format: "%.f", dailyModel.temp.max)
            lowTempLabelString = String(format: "%.f", dailyModel.temp.min)
            urlString = "http://openweathermap.org/img/wn/\(dailyModel.weather[0].icon)@2x.png"
            iconImageView.downloaded(from: urlString ?? "")
            if dailyModel.humidity >= 30 {
                humidityLabelString = String(dailyModel.humidity) + " %"
            } else {
                humidityLabelString = ""
            }
        }        
        return DailyTableViewCellViewModel(dayLabelString: dayLabelString,
                                           highTempLabelString: highTempLabelString,
                                           lowTempLabelString: lowTempLabelString,
                                           humidityLabelString: humidityLabelString,
                                           iconImage: iconImage,
                                           urlString: urlString)
    }
    
    func setupCell(_ viewModel: DailyTableViewCellViewModel) {
        dayLabel.text = viewModel.dayLabelString
        highTempLabel.text = viewModel.highTempLabelString
        lowTempLabel.text = viewModel.lowTempLabelString
        humidityLabel.text = viewModel.humidityLabelString
        iconImageView.image = viewModel.iconImage
    }
    
    
}
