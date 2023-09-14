//
//  SearchController.swift
//  TwitchClipsforWatch WatchKit Extension
//
//  Created by Reuben on 19/06/21.
//

import WatchKit

class SearchController: WKInterfaceController {
    
    @IBOutlet weak var searchTable: WKInterfaceTable!
    @IBOutlet weak var noResults: WKInterfaceLabel!
    
    var channels: [Channel] = []
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.pushController(withName: "YT", context: channels[rowIndex])
    }
        
    override func awake(withContext context: Any?) {
        
        noResults?.setHidden(true)
        
        if let context = context as? [Channel] {
            
            self.setTitle("Favorites")
            
            channels = context
            
            self.refresh()
            return
        }
        
        sendRequest("https://api.twitch.tv/helix/search/channels", parameters: ["query": (context as? String) ?? ""], headers: ["Authorization": AUTH_TOKEN, "Client-Id": CLIENT_ID]) { response, error  in
        
               if let JSON = response {
                
                let decoder = JSONDecoder()
                
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let result = try! decoder.decode(ResultChannel.self, from: JSON)
                
                print(result.data)
                
                self.channels = result.data
                
                self.refresh()
                   
                
               }
        }
    }
    
    func refresh(){
        
        searchTable?.setHidden(false)
        
        self.searchTable?.setNumberOfRows(channels.count, withRowType: "SearchRow")
        
        if searchTable?.numberOfRows == 0 {
            noResults.setHidden(false)
        }
        
        for index in 0..<(self.searchTable?.numberOfRows ?? 0){
            
            let row = self.searchTable?.rowController(at: index) as? SearchRowController
            row?.channel = channels[index]
            
        }
        
    }
}
