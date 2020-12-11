//
//  ViewController.swift
//  News
//
//  Created by Павло Тимощук on 31.10.2020.
//

import UIKit
import SafariServices

class NewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var newsTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var filteredNews = [News]()
    var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    //MARK: - Refresh
    var refresh = UIRefreshControl()
    
    @objc func handleRefresh()
    {
        gettingNews()
        self.newsTableView.reloadData()
        refresh.endRefreshing()
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        gettingNews()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        newsTableView.addSubview(refresh)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        if #available(iOS 11.0, *) {
            self.newsTableView.tableHeaderView = self.searchController.searchBar
        }
        definesPresentationContext = true
    }
    
    //MARK: - Getting news from server
    func gettingNews() {
        newsArray.removeAll()
        let urlString = "https://newsapi.org/v2/top-headlines?" +
            "country=ua&" +
            "apiKey=16addd21bdf045df983057352f0e0b2b"
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) {
                data, response, error in
                if let data = data {
                    let rootDirectory = try? (JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String, Any>)
                    let array = rootDirectory!["articles"] as! [Dictionary<String, Any>]
                    for item in array {
                        newsArray.append(News(dictionary: item))
                    }
                    DispatchQueue.main.async {
                        self.newsTableView.reloadData()
                    }
                }
            }.resume()
        }
    }
    
    //MARK: - tableView numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //MARK: - Filtering
        if isFiltering {
            return filteredNews.count
        } else {
            return newsArray.count
        }
        
    }
    
    //MARK: - tableView cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as? NewsTableViewCell {
            //MARK: - Filtering
            let news: News
            if isFiltering {
                news = filteredNews[indexPath.row]
            } else {
                news = newsArray[indexPath.row]
            }
            cell.newsTitleLabel?.text = news.newsTitle
            cell.newsSourceLabel?.text = news.newsSource
            cell.newsDescriptionLabel?.text = news.newsDescription
            cell.showNewsDetailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDetail)))
            cell.showNewsDetailView.isUserInteractionEnabled = true
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = formatter.date(from: news.newsTime) {
                formatter.dateFormat = "HH:mm"
                cell.newsTimeLabel?.text = formatter.string(from: date)
            } else {
                cell.newsTimeLabel?.text = ""
            }
            if let newsImageUrl = news.urlImage {
                newsTableView.rowHeight = 150
                cell.newsTitleLabel?.frame.origin.y = 60
                cell.newsSourceLabel?.frame.origin.y = 90
                cell.newsDescriptionLabel?.frame.origin.y = 120
                cell.newsTimeLabel?.frame.origin.y = 60
                if let url = URL(string: newsImageUrl) {
                    let data = try? Data(contentsOf: url)
                    if let imageData = data {
                        cell.newsImage.image = UIImage(data: imageData)
                    }
                }
            } else {
                newsTableView.rowHeight = 100
                cell.newsTitleLabel?.frame.origin.y = 10
                cell.newsSourceLabel?.frame.origin.y = 40
                cell.newsDescriptionLabel?.frame.origin.y = 70
                cell.newsTimeLabel?.frame.origin.y = 10
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    //MARK: - Show news detail
    @objc func showDetail(_ sender:UITapGestureRecognizer) {
        if #available(iOS 11.0, *) {
            var pointValue = CGPoint()
            pointValue = sender.location(in: newsTableView)
            var indexPath = IndexPath()
            indexPath = newsTableView.indexPathForRow(at: pointValue)!
            let news: News
            if isFiltering {
                news = filteredNews[indexPath.row]
            } else {
                news = newsArray[indexPath.row]
            }
            if let url = URL(string: news.newsDetailURL) {
                print(news.newsDetailURL)
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let vc = SFSafariViewController(url: url, configuration: config)
                let searchedТext = searchController.searchBar.text!
                searchController.isActive = false
                isFiltering ? searchController.present(vc, animated: true, completion: nil) : present(vc, animated: true, completion: nil)
                searchController.searchBar.text = searchedТext
            }
        }
    }
    
    //MARK: - SearchResults
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredNews = newsArray.filter({ (news: News) -> Bool in
            return news.newsTitle.lowercased().contains(searchText.lowercased()) || news.newsSource.lowercased().contains(searchText.lowercased()) || news.newsDescription.lowercased().contains(searchText.lowercased())
        })
        newsTableView.reloadData()
    }
    
    //MARK: - didSelectRowAt
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        if #available(iOS 11.0, *) {
    //            if let url = URL(string: newsArray[indexPath.row].newsDetailURL) {
    //                let config = SFSafariViewController.Configuration()
    //                config.entersReaderIfAvailable = true
    //                let vc = SFSafariViewController(url: url, configuration: config)
    //                present(vc, animated: true, completion: nil)
    //            }
    //        }
    //    }
    
}
