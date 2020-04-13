//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "812E0E0C-6A87-413A-929A-8F626A3C8441"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with url: String) {
        if let url = URL(string: url) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, urlResponse, error) in
                if error != nil {
                    print(error!)
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
//                    let stringifiedData = String(data: safeData, encoding: String.Encoding.utf8)!
                    if let coinData = self.parseJson(safeData) {
                        self.delegate?.didUpdateUI(self, data: coinData)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJson(_ data: Data) -> CoinData? {
        let decoder = JSONDecoder()
        do {
            // 미리 만들어놓은 CoinData 틀에 맞춰서 JSON 해독하게 하기
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let rate = decodedData.rate
            let currency = decodedData.asset_id_quote
            let coinData = CoinData(rate: rate, asset_id_quote: currency)
            return coinData
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

protocol CoinManagerDelegate {
    func didUpdateUI(_ sender: CoinManager, data: CoinData)
    func didFailWithError(error: Error)
}
