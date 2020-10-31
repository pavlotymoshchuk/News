//
//  ViewController.swift
//  News
//
//  Created by Павло Тимощук on 31.10.2020.
//

import UIKit
import SafariServices

class NewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var newsTableView: UITableView!
    
    //MARK: - Refresh
    var refresh = UIRefreshControl()
    
    @objc func handleRefresh()
    {
        gettingNews()
        self.newsTableView.reloadData()
        refresh.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gettingNews()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        newsTableView.addSubview(refresh)
        newsTableView.rowHeight = 100
    }
    
    func gettingNews()
    {
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
    
    func showDetail(_ link: String) {
        if let url = URL(string: link) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        newsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as? NewsTableViewCell {
            let news = newsArray[indexPath.row]
            cell.newsTitleLabel?.text = news.newsTitle
            cell.newsSourceLabel?.text = news.newsSource
            cell.newsDescriptionLabel?.text = news.newsDescription
            cell.newsTimeLabel?.text = news.newsTime
//            if let newsImageUrl = news.urlImage {
//                newsTableView.rowHeight = 150
//                cell.newsTitleLabel?.frame.origin.y += 50
//                cell.newsSourceLabel?.frame.origin.y += 50
//                cell.newsDescriptionLabel?.frame.origin.y += 50
//                cell.newsTimeLabel?.frame.origin.y += 50
//                
//                let url = URL(string: newsImageUrl)!
//                let data = try? Data(contentsOf: url)
//                cell.newsImage.image = UIImage(data: data!)
//                cell.newsImage.frame.size = CGSize(width: view.frame.width, height: 50)
//                cell.newsImage.frame.origin = CGPoint(x: 0, y: 0)
//            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetail(newsArray[indexPath.row].newsDetailURL)
    }

}

