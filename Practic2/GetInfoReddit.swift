//
//  GetInfoReddit.swift
//  Practic2
//
//  Created by лізушка лізушкіна on 24.02.2023.
//

import Foundation

public class GetInfoReddit: Codable
{
    var subreddit: String
    var limit: Int
    var after: String
    var pageInfoList : [Post]?
    
    init(subreddit: String, limit: Int, after: String)
    {
        self.subreddit = subreddit
        self.limit = limit
        self.after = after
        parseJSON()
    }
    
    private func makeSaving () -> Bool
    {
        return.random()
    }
    
    private func timeElapsed(createdDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        let currentTime = Date()
        let timeElapsed = currentTime.timeIntervalSince(createdDate)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        let formattedString = formatter.string(from: timeElapsed)!
        return formattedString
    }
    
    public func parseJSON()
    {
        //var savedPosts: SavedManager = SavedManager()
        var info: [String:String] = [:]
        var allInfo :[Post] = []
        var link: String = "https://www.reddit.com/r/"+self.subreddit+"/top.json?limit="+String(self.limit)
        
        if (self.after != "")
        {
            link += "&after="+self.after
        }
        guard let url = URL(string:link)
        else
        {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print("Error with data")
                return
            }
            do
            {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else
                {
                    print("Invalid JSON")
                    return
                }
                if let data = json["data"] as? [String:Any],
                   let after = data["after"] as? String,
                   let children = data["children"] as? [[String:Any]]
                {
                    for child in children {
                        if let childData = child["data"] as? [String:Any],
                           let domain = childData["domain"] as? String,
                           let authorFullName = childData["author"] as? String,
                           let title = childData["title"] as? String,
                           let ups = childData["ups"] as? Int,
                           let downs = childData["downs"] as? Int,
                           let commentsNum = childData["num_comments"] as? Int,
                           let createdUTC = childData["created_utc"] as? Double
                        {
                            let createdDate = Date(timeIntervalSince1970: createdUTC)
                            let time = self.timeElapsed(createdDate: createdDate)
                            let rating = ups+downs
                            info["UpperLabel"] = authorFullName + " • " + time + " • " + domain
                            info["Title"]=title
                            info["Rating"] = String(rating)
                            info["Comments"] = String(commentsNum)
                            self.after = after
                            if let image = childData["url_overridden_by_dest"] as? String{
                                info ["Image"] = image
                            }
                            let saved = self.makeSaving()
                            info["Saved"] = String(saved)
                            if let permalink = childData["permalink"] as? String
                            {
                                let urlPost = "https://www.reddit.com" + permalink
                                info["Url"] = urlPost
                            }
                            let post = Post()
                            post.reddit = info
                            allInfo.append(post)
                            info["Image"] = nil
                            self.pageInfoList=allInfo
                        }
                        else {
                            print("Error: Could not extract values")
                            return
                        }
                    }
                }
                
            }
            
        }
        task.resume()
    }
}
