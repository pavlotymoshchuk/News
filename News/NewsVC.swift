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
    }
    
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        newsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as? NewsTableViewCell {
            let news = newsArray[indexPath.row]
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

                let url = URL(string: newsImageUrl)
                let data = try? Data(contentsOf: url!)
                if let imageData = data {
                    cell.newsImage.image = UIImage(data: imageData)
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
    
    @objc func showDetail(_ sender:UITapGestureRecognizer) {
        if #available(iOS 11.0, *) {
            var pointValue = CGPoint()
            pointValue = sender.location(in: newsTableView)
            var indexPath = IndexPath()
            indexPath = newsTableView.indexPathForRow(at: pointValue)!
            if let url = URL(string: newsArray[indexPath.row].newsDetailURL) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let vc = SFSafariViewController(url: url, configuration: config)
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
   
    
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
