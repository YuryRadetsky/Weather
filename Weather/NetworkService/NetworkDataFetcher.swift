//
//  NetworkDataFetcher.swift
//  Weather
//
//  Created by Yury Radetsky on 12.04.2021.
//

import Foundation

protocol DataFetcher {
    func fetchData<T: Codable>(urlString: String, completion: @escaping (T?) -> Void)
}

class NetworkDataFetcher: DataFetcher {
    
    func fetchData<T: Codable>(urlString: String, completion: @escaping (T?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(response)
                }
            }
            catch let jsonError {
                print("Failed to decode frome JSON", jsonError)
            }
        }.resume()
    }
    
}
