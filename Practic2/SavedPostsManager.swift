//
//  SavedPostsManager.swift
//  Practic2
//
//  Created by лізушка лізушкіна on 10.03.2023.
//

import Foundation

class SavedPostsManager
{
    var savedPosts: [Post] = []
    var filteredPosts: [Post] = []
    private var fileName = "savedPosts.json"
    
    
    func saveJSON()
    {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(self.savedPosts)
        {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(self.fileName)
            do {
                try encodedData.write(to: fileURL)
            } catch {
                print("Error in saving")
            }
        }
    }
    
    func loadPostsJSON()
    {
        let decoder = JSONDecoder()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(self.fileName)
        do {
            let data = try Data(contentsOf: fileURL)
            let posts = try decoder.decode([Post].self, from: data)
            self.savedPosts = posts
        } catch {
            print("Error in loading")
            return
        }
    }
    
    

    func makeSaved(allPosts: [Post])
    {
        if allPosts.isEmpty
        {
            self.loadPostsJSON()
        }
        else
        {
            clearJson()
            for post in allPosts {
                if let saved = post.reddit["Saved"]
                {
                    if saved == "true"
                    {
                        self.savePost(post: post)
                    }
                }
            }
            if self.savedPosts[0].reddit == [:]
            {
                self.savedPosts.removeFirst()
            }
            if self.savedPosts[self.savedPosts.endIndex-1].reddit == [:]
            {
                self.savedPosts.removeLast()
            }
            saveJSON()
        }
    }
    
    func clearJson()
    {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(self.fileName)
        do {
            try "".write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error in cleaning")
        }
    }

    func savePost(post: Post)
    {
        let containsExactPost = self.savedPosts.contains { $0.reddit == post.reddit }
        if post.reddit != [:] && !containsExactPost
        {
            self.savedPosts.append(post)
            clearJson()
            saveJSON()
        }
    }

    func deletePost(post: Post)
    {
        let newList = self.savedPosts.filter { $0.reddit != post.reddit }
        self.savedPosts = newList
        clearJson()
        saveJSON()
    }
}
