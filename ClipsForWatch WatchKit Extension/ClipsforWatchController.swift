//
//  ClipsforWatchController.swift
//  TwitchClipsforWatch
//
//  Created by Reuben on 5/07/21.
//

import WatchKit

class ClipsforWatchController: WKInterfaceController {

    @IBAction func tapSearch() {
        
        self.presentTextInputController(withSuggestions: [], allowedInputMode: .allowEmoji, completion: { response in
            
            let text = (response as? [String])?.first
            
            
            if(text != nil){
            
                self.pushController(withName: "Search", context: text)
                
            }
            
        })
        
    }
    
    @IBAction func tapFavourites() {
        
        let settings = UserDefaults.standard
        
        let decoder = JSONDecoder()
        guard let favourites = try? decoder.decode(Array.self, from: settings.data(forKey: "favourites") ?? Data()) as [Channel] else {
            self.pushController(withName: "Search", context: [])
             return
         }

        self.pushController(withName: "Search", context: favourites)
        
    }
    
    
}
