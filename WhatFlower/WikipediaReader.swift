//
//  WikipediaReader.swift
//  WhatFlower
//
//  Created by Jarek on 26/03/2018.
//  Copyright © 2018 Jarek. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WikipediaReader {
    let wikipediaApiUrl = "https://en.wikipedia.org/w/api.php"
    
    func readExtract(about topic: String, completion: @escaping (String, String) -> Void) {
        let apiParameters = ["action": "query",
                         "prop":"extracts|pageimages",
                         "format":"json",
                         "indexpageids":"",
                         "redirects":"1",
                         "exintro":"",
                         "explaintext":"",
                         "pithumbsize":"500",
                         "titles":topic]
        
        Alamofire.request(wikipediaApiUrl, method: .get, parameters: apiParameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Wikipedia data retrieved...")
                
                let wikipediaExtract = JSON(response.result.value!)
                if let pageId = wikipediaExtract["query"]["pageids"][0].string {
                    if let extract = wikipediaExtract["query"]["pages"][pageId]["extract"].string {
                        print("Wikipedia Extract: \(extract)")
                        
                        let imageUrl = wikipediaExtract["query"]["pages"][pageId]["thumbnail"]["source"].stringValue
                        
                        completion(extract, imageUrl)
                    }
                }
            } else {
                print("Reading wikipedia failed: \(response.result.error!.localizedDescription)")
                completion("", "")
            }
        }
    }
}
