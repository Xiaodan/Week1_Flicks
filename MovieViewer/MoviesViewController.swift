//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Sally Zhang on 10/15/16.
//  Copyright © 2016 Sally Zhang. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    var endpoint: String!
    var refreshControl: UIRefreshControl!
    
    var errorMsgView = UIView()
    var errorMsgLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // error msg
        errorMsgView.frame = CGRect(x: 20, y: 64, width: 342, height: 30)
        errorMsgLabel.frame = CGRect(x: 20, y: 47, width: 342, height: 30)
        errorMsgView.backgroundColor = UIColor.orange
        errorMsgLabel.text = "Network Error! :( Check Network Settings. "
        errorMsgLabel.font = errorMsgLabel.font.withSize(14)
        errorMsgLabel.sizeToFit()
        errorMsgLabel.center = CGPoint(x: errorMsgView.frame.width/2, y: errorMsgView.frame.height/2)
        errorMsgView.insertSubview(errorMsgLabel, at: 0)
        errorMsgView.isHidden = true
        UIApplication.shared.keyWindow?.addSubview(errorMsgView)
        
        refreshControl = UIRefreshControl()
        //refreshControl.addTarget(self, action: Selector("didRefresh"), for: UIControlEvents.valueChanged)
        refreshControl.addTarget(self, action: #selector(MoviesViewController.didRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 1)
        
        // Do any additional setup after loading the view.
        networkRequest()
    }
    
    func networkRequest() {
        let apiKey = "99ba63a6d6e90dfbc52007ba9e943a79"
        // print(endpoint)
        // add an ! to endpoint
        let url = URL(string:"http://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10
        
        let session = URLSession(
            configuration: sessionConfig,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            
            if let data = dataOrNil {
                // want it to be used later
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    print("response: \(responseDictionary)")
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    
                    // REMEMBER TO reload data after network requests have been made
                    self.tableView.reloadData()
                    
                    // Error msg disappears when the internet is back
                    if(self.errorMsgView.isHidden == false) {
                        self.errorMsgView.isHidden = true
                    }
                    // Hide HUD right before the request is made
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            } else { // nil data
                // REMEMBER TO reload data after network requests have been made
                self.tableView.reloadData()
                
                // Hide HUD right before the request is made
                MBProgressHUD.hide(for: self.view, animated: true)
                
                self.errorMsgView.isHidden = false
                print("There was a network error!")
            }
        })
        task.resume()
        
    }
    
    func didRefresh(_ refreshControl: UIRefreshControl) {
        networkRequest()
        print("did refresh")
        self.refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        // downcast
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        // safely get images
        let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            cell.posterView.setImageWith(posterUrl! as URL)
        }
            
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterView.image = nil
        }
        
        // cell.textLabel!.text = "row \(indexPath.row)"
        // cell.textLabel!.text = title
        
        // cell.selectionStyle = .none
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 174/255, green: 242/255, blue: 235/255, alpha: 0.75)
        cell.selectedBackgroundView = backgroundView
        
        // print("row \(indexPath.row)")
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //print("prepare for segue called")
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailsViewController = segue.destination as! DetailsViewController
        detailsViewController.movie = movie
        
        
        
    }
    

}
