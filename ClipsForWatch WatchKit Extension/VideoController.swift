//
//  VideoController.swift
//  YT WatchKit Extension
//
//  Created by Reuben Catchpole on 23/11/19.
//  Copyright © 2019 Reuben Catchpole. All rights reserved.
//

import WatchKit
import WatchConnectivity
import AVFoundation

func sendRequest(_ url: String, parameters: [String: String] = [:], headers: [String: String] = [:], completion: @escaping (Data?, Error?) -> Void) {
    var components = URLComponents(string: url)!
    components.queryItems = parameters.map { (key, value) in
        URLQueryItem(name: key, value: value)
    }
    components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    
    var request = URLRequest(url: components.url!)
    
    for header in headers{
        request.setValue(header.1, forHTTPHeaderField: header.0)
    }
    

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        
        print(String(data: data!, encoding: .utf8))
        
        
        guard let data = data,                            // is there data
            let response = response as?  HTTPURLResponse,  // is there HTTP response
            (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
            error == nil else {                           // was there no error, otherwise ...
                completion(nil, error)
                return
        }

        completion(data, nil)
    }
    task.resume()
}



class VideoController: WKInterfaceController {
    
    var channel = Channel(id: "217377982", displayName: "", thumbnailUrl: "")
    
    @IBOutlet weak var favouriteIcon: WKInterfaceImage!
    @IBOutlet weak var favouriteText: WKInterfaceLabel!
    
    
    @IBOutlet weak var noClips: WKInterfaceLabel!
    @IBOutlet weak var searchGroup: WKInterfaceGroup!
    @IBOutlet weak var ai: WKInterfaceImage!
    
    @IBOutlet weak var table: WKInterfaceTable?
    
    var clips: [Clip] = []
    
    @IBAction func tapFavourite() {
        
        let settings = UserDefaults.standard
        
        guard let encoded = settings.data(forKey: "favourites") else {
            let encoder = JSONEncoder()
              if let encoded = try? encoder.encode([channel]){
                  settings.setValue(encoded, forKey: "favourites")
              }
            return
        }
        
        let decoder = JSONDecoder()
        guard var favourites = try? decoder.decode(Array.self, from: encoded) as [Channel] else {
             return
         }
        
        
        if(favourites.contains(where: { $0.id == channel.id })){
            favouriteText.setText("Favorite")
            favouriteIcon.setImage(UIImage(systemName: "star.fill"))
            if let index = favourites.firstIndex(where: { $0.id == channel.id}) {
                favourites.remove(at: index)
            }
            
            let encoder = JSONEncoder()
              if let encoded = try? encoder.encode(favourites){
                  settings.setValue(encoded, forKey: "favourites")
              }
            
            print(favourites)
            return
        }
        
        favourites.append(channel)
        
        let encoder = JSONEncoder()
          if let encoded = try? encoder.encode(favourites){
              settings.setValue(encoded, forKey: "favourites")
          }
        
        favouriteText.setText("Unfavorite")
        favouriteIcon.setImage(UIImage(systemName: "star.slash.fill"))
        print(favourites)
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int){
        
        
        //self.pushController(withName: "Video", context: self.videos?[rowIndex])
        
        self.presentMediaPlayerController(with: URL(string: (self.clips[rowIndex].thumbnailUrl ?? "").components(separatedBy: "-preview")[0] + ".mp4")!){ _,_,_ in
            
        }
        
        
        
    }
    
    let session = WCSession.default
    
    @objc func clearCache(){
        
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let filePaths = try? FileManager.default.contentsOfDirectory(atPath: documentsDirectoryURL.relativePath)
        
        for filePath in filePaths ?? [] {

            try? FileManager.default.removeItem(atPath: documentsDirectoryURL.relativePath + "/" + filePath)
        }
        
    }
    
    override func awake(withContext context: Any?) {
        
        searchGroup.setHidden(true)
        table?.setHidden(true)
        noClips.setHidden(true)
        
        if let _channel = context as? Channel {
            self.setTitle(_channel.displayName)
            channel = _channel
        }
        
        let settings = UserDefaults.standard
        
        if let encoded = settings.data(forKey: "favourites") {
        
        let decoder = JSONDecoder()
        if let favourites = try? decoder.decode(Array.self, from: encoded) as [Channel] {
        
            if(favourites.contains(where: { $0.id == channel.id })){
                favouriteText.setText("Unfavorite")
                favouriteIcon.setImage(UIImage(systemName: "star.slash.fill"))
            }
                
        }
            
        }
        
        sendRequest("https://api.twitch.tv/helix/clips", parameters: ["broadcaster_id":channel.id, "first":"100"], headers: ["Authorization": AUTH_TOKEN, "Client-Id": CLIENT_ID]) { response, error  in
                
            
                   if let JSON = response {
                    
                    let decoder = JSONDecoder()
                    
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let result = try! decoder.decode(ResultClip.self, from: JSON)
                    
                       
                    self.clips = result.data
                    
                    self.refresh()
                        
                    
                   }
                }
            
    }
        
    
    
    func refresh(){
        
        self.ai.setHidden(true)
        //searchGroup.setHidden(false)
        table?.setHidden(false)
        
        self.table?.setNumberOfRows(clips.count, withRowType: "VideoRow")
        
        if table?.numberOfRows == 0 {
            noClips.setHidden(false)
        }
        
        for index in 0..<(self.table?.numberOfRows ?? 0){
            
            let row = self.table?.rowController(at: index) as? VideoRowController
            row?.clip = clips[index]
            
        }
        
    }
    
}

public func imageDataFromUrl(_ urlString: String, completion: @escaping (Data) -> ()){
       
       if let url = URL(string: urlString) {
           
           let request = URLRequest(url: url)
           let config = URLSessionConfiguration.default
           let session = URLSession(configuration: config)
           
           let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
               
               if let imageData = data {
                   
                   DispatchQueue.global().async {
                    
                    completion(imageData)
                       
                   }
                
               }
           });
           
           task.resume()
           
       }
   }

extension String {

  func getYoutubeFormattedDuration() -> String {

    let formattedDuration = self.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with:":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")

    let components = formattedDuration.components(separatedBy: ":")
    var duration = ""
    for component in components {
        duration = duration.count > 0 ? duration + ":" : duration
        
        if component.count < 2 {
            duration += "0" + component
            continue
        }
        duration += component
    }
    
    if(duration.hasPrefix("0")){
        duration = String(duration.dropFirst())
    }
    
    if(!duration.contains(":")){
        duration = "0:" + duration
    }

    return duration

}

}

