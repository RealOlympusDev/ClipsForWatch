//
//  Video.swift
//  YT WatchKit Extension
//
//  Created by Reuben Catchpole on 23/11/19.
//  Copyright © 2019 Reuben Catchpole. All rights reserved.
//

import Foundation

public struct Clip: Codable {
    
    var id: String = ""
    var title: String = ""
    var thumbnailUrl: String = ""
    var broadcasterName: String = ""
    var viewCount: Int = 0
    var duration: Double = 0.0
    
    
}

public struct ResultClip: Codable {
    
    var data: [Clip] = []
    
}
