//
//  SearchRowController.swift
//  TwitchClipsforWatch WatchKit Extension
//
//  Created by Reuben on 19/06/21.
//

import Foundation
import WatchKit

class SearchRowController: NSObject {
    
    @IBOutlet weak var profilePic: WKInterfaceImage!
    @IBOutlet weak var channelName: WKInterfaceLabel!
    
    var channel: Channel? {
          
          didSet {
            
            channelName.setText(channel?.displayName)
            
            
            imageDataFromUrl(channel?.thumbnailUrl ?? "") { data in
                
                self.profilePic.setImageData(data)
                
            }
            
            
          }
        
    }
    
    
}
