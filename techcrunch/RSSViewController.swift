//
//  RSSViewController.swift
//  techcrunch
//
//  Created by Adela Chang on 2016/01/13.
//  Copyright (c) 2016年 Adela Chang. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

class RSSTableViewCell : UITableViewCell {
}

class RSSViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Alamofire.request(.GET, "http://feeds.feedburner.com/TechCrunch/social?fmt=xml", parameters: nil)
            .response { (request, response, data, error) in
            let xml = SWXMLHash.parse(data!)
            for elem in xml["rss"]["channel"]["item"] {
                print(elem["title"])
                print(elem["pubDate"])
                print(elem["description"])
                print("\n----\n")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}

