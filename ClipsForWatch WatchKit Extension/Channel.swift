//
//  Channel.swift
//  TwitchClipsforWatch WatchKit Extension
//
//  Created by Reuben on 19/06/21.
//

import Foundation

public struct Channel: Codable {
    
    var id: String = ""
    var displayName: String = ""
    var thumbnailUrl: String = ""
    
}

public struct ResultChannel: Codable {
    
    var data: [Channel] = []
    
}
