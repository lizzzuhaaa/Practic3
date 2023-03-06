//
//  PostListViewController.swift
//  Practic2
//
//  Created by лізушка лізушкіна on 03.03.2023.
//

import Foundation
import UIKit

class PostListViewController: UIViewController
{
    var mainReddit: GetInfoReddit = GetInfoReddit(subreddit:"ios", limit: 10, after: "")
    @IBOutlet private weak var subredName: UILabel!
    @IBOutlet private weak var savingFilter: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private weak var searchField: UITextField!
    private var saved:Bool = false
    
    private var allSearching : [Post] = []
    
    private var savedPosts : SavedPostsManager = SavedPostsManager()
    private var allRedditList : [Post] = []
    private var currentReddit: Post = Post()
    private var postsLimit:Int = 10
    private var isLoad:Bool = false
    private var page:Int = 0
    
    
    private var numberOfCells: [Int] = []
    
    private struct Const
    {
        static let cellReuseIndendifier = "my_custom_cell"
        static let goToPost = "go_to_post"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let posts = mainReddit.pageInfoList{
            self.allRedditList = posts
            self.mainReddit.parseJSON()
        }
        
        self.numberOfCells = Array(0..<(self.postsLimit))
        self.tableView.delegate = self
        self.searchField.isHidden = true
        self.searchField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier
        {
        case Const.goToPost:
            let nextVC = segue.destination as! PostDetailsViewController
            nextVC.redditMake(redditCurrent: self.currentReddit, saved: self.savedPosts)
        default:
            break
        }
    }
    
    @IBAction func onSavinClick(_ sender: Any) {
        
        if self.saved
        {
            self.savingFilter.setImage(UIImage(systemName:"bookmark"), for: .normal)
            self.searchField.isHidden = true
            self.savedPosts.filteredPosts = []
            self.allSearching = []
            self.saved = false
        }
        else
        {
            self.savingFilter.setImage(UIImage(systemName:"bookmark.fill"), for: .normal)
            self.searchField.isHidden = false
            self.savedPosts.makeSaved(allPosts: self.allRedditList)
            self.allSearching = self.savedPosts.savedPosts
            self.savedPosts.filteredPosts = self.allSearching
            self.saved = true
        }
        self.tableView.reloadData()
    }
    
    func upLoad()
    {
        
        if !isLoad {
            isLoad = true
            self.mainReddit.parseJSON()
                if let nextPage = mainReddit.pageInfoList
                {
                    self.allRedditList += nextPage
                    self.mainReddit.pageInfoList = nil
                    self.postsLimit+=10
                    self.numberOfCells=Array(0..<self.postsLimit)
                    
                    let newSaved: SavedPostsManager = SavedPostsManager()
                    newSaved.makeSaved(allPosts: nextPage)
                    let newSavedList = newSaved.savedPosts
                    for post in newSavedList
                    {
                        self.savedPosts.savePost(post: post)
                    }
                    self.allSearching = self.savedPosts.savedPosts
                    self.tableView.reloadData()
                }
            self.isLoad = false
        }
    }
}

extension PostListViewController: UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.savedPosts.filteredPosts.isEmpty
        {
            return self.savedPosts.filteredPosts.count
        }
        return self.numberOfCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellReuseIndendifier, for: indexPath) as! MyCustomCell
        self.page = indexPath.row

        if !self.savedPosts.filteredPosts.isEmpty
        {
            let particularPost = self.savedPosts.filteredPosts[self.page].reddit
            cell.config(reddit: particularPost)
        }
        else if !self.allRedditList.isEmpty
        {
            let particularPost = allRedditList[self.page].reddit
            cell.config(reddit: particularPost)
        }
        return cell
    }
}

extension PostListViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.savedPosts.filteredPosts.isEmpty
        {
            self.currentReddit = self.savedPosts.filteredPosts[indexPath.row]
            self.performSegue(withIdentifier: Const.goToPost, sender: nil)
        }
        else if !allRedditList.isEmpty
        {
            self.currentReddit = allRedditList[indexPath.row]
            self.performSegue(withIdentifier: Const.goToPost, sender: nil)
        }
    }
}

extension PostListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height
        {
            if ((self.page + 1) % 10 == 0)
            {
                self.upLoad()
            }
        }
    }
}

extension PostListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        self.savedPosts.filteredPosts = self.allSearching.filter
        {
            if let currentPost = $0.reddit["Title"]
            {
               return currentPost.lowercased().contains(searchText.lowercased())
            }
            return false
        }
        if self.savedPosts.filteredPosts.isEmpty || searchText.count == 0
        {
            self.savedPosts.filteredPosts = self.allSearching
        }
        self.tableView.reloadData()
        return true
    }
}
