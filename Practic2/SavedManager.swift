//
//  SavedManager.swift
//  Practic2
//
//  Created by лізушка лізушкіна on 10.03.2023.
//

import Foundation

public class SavedManager
{
    var posts: [[String:String]] = []
    private let fileName = "saved_posts.txt"
    
    func savePosts(post: [String:String])
    {
        if post != [:]
        {
            self.posts += [post]
        }
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
        do {
            var text = ""
            for item in posts {
                for (key, value) in item {
                    text += "\(key):\(value)\t"
                }
                text += "\n"
            }
            try text.write(to: fileURL!, atomically: false, encoding: .utf8)
        } catch {
            print("Error in saving")
        }
    }
    
    func deletePost(post: [String:String])
    {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
        do {
           let text = try String(contentsOf: fileURL!, encoding: .utf8)
            let lines = text.components(separatedBy: .newlines)
           
        //lines.removeLast()
        
           var newPosts: [[String: String]] = []
           for line in lines {
               var p: [String: String] = [:]
               let pairs = line.components(separatedBy: "\t")
               for pair in pairs {
                   let components = pair.components(separatedBy: ":")
                   p[components[0]] = components[1]
               }
               if p != post {
                   newPosts.append(p)
               }
           }
            self.posts = newPosts
               // Записуємо новий список словників у файл
            self.savePosts(post: [:])
//               var newText = ""
//               for item in newData {
//                   for (key, value) in item {
//                       newText += "\(key):\(value)\t"
//                   }
//                   newText += "\n"
//               }
//               try newText.write(to: fileURL!, atomically: false, encoding: .utf8)
           } catch {
               print("Error in deleting")
           }
    }
}
