//
//  VideoRowController.swift
//  YT WatchKit Extension
//
//  Created by Reuben Catchpole on 23/11/19.
//  Copyright © 2019 Reuben Catchpole. All rights reserved.
//

import Foundation
import WatchKit

class VideoRowController: NSObject {
    
    @IBOutlet weak var thumbnail: WKInterfaceImage?
    @IBOutlet weak var videoTitle: WKInterfaceLabel?
    @IBOutlet weak var channelName: WKInterfaceLabel?
    @IBOutlet weak var views: WKInterfaceLabel?
    @IBOutlet weak var duration: WKInterfaceLabel!
    
    var clip: Clip? {
          
          didSet {
            
            videoTitle?.setText(clip?.title.replacingOccurrences(of: "&#39;", with: "'"))
            
            channelName?.setText(clip?.broadcasterName)
            
            views?.setText((formatNumber(String(clip?.viewCount ?? 0))) + " views")
            
            duration.setText(String(clip?.duration ?? 0.0) + "s")
            
            imageDataFromUrl(clip?.thumbnailUrl ?? "", completion: { data in
                
                self.thumbnail?.setImageData(data)
                
            })
            
            
          }
        
    }
    
    
}


extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

func formatNumber(_ n: String) -> String {
       
   let n = Int(n) ?? 0

   let num = Double(abs(n))
   let sign = (n < 0) ? "-" : ""

   switch num {
       
   case 10_000_000_000...:
   var formatted = num / 1_000_000_000
   formatted = formatted.truncate(places: 1)
   return "\(sign)\(Int(formatted))B"

   case 1_000_000_000...:
       var formatted = num / 1_000_000_000
       formatted = formatted.truncate(places: 1)
       return formatted.truncate(places: 1).clean + "B"
       
   case 100_000_000...:
       var formatted = num / 1_000_000
       formatted = formatted.truncate(places: 1)
       return "\(sign)\(Int(formatted))M"
       
   case 10_000_000...:
       var formatted = num / 1_000_000
       formatted = formatted.truncate(places: 1)
       return "\(sign)\(Int(formatted))M"

   case 1_000_000...:
       let formatted = num / 1_000_000
       return formatted.truncate(places: 1).clean + "M"

   case 1_000...:
       var formatted = num / 1_000
       formatted = formatted.truncate(places: 0)
       return "\(sign)\(Int(formatted))K"

   case 0...:
       return "\(n)"

   default:
       return "\(sign)\(n)"

   }
   }
