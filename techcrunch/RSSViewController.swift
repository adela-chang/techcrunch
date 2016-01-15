//
//  RSSViewController.swift
//  techcrunch
//
//  Created by Adela Chang on 2016/01/13.
//  Copyright (c) 2016年 Adela Chang. All rights reserved.
//
import Alamofire
import SWXMLHash

import UIKit

class RSSTableViewCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

class RSSViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var rssTableView: UITableView!
    @IBOutlet weak var noContentLabel: UILabel!
    
    var rssData:NSMutableArray = NSMutableArray()

    //MARK: - Custom Methods
    func reloadData() {
        if (self.rssData.count > 0) {
            self.noContentLabel.hidden = true
        } else {
            self.noContentLabel.hidden = false
        }
        
        self.rssTableView.reloadData()
    }
    
    func parseFeedburnerLink(url:String) {

        Alamofire.request(.GET, url, parameters: nil).response { (request, response, data, error) in
            let xml = SWXMLHash.parse(data!)
            for elem in xml["rss"]["channel"]["item"] {

                //parse xml
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEE, d MMM YYYY HH:mm:ss +SSSS"
                let date = dateFormatter.dateFromString(elem["pubDate"].element!.text!)!

                //remove html tags/encoding from description
                let desc = elem["description"].element!.text!.stringByDecodingHTMLEntities.stringByStrippingHTMLTags
                
                let item = RSSItem()
                item.title = elem["title"].element!.text!;
                item.date = date;
                
                //note: using substring bc techcrunch always has an extra space in front of its descriptions, and extraneous "Read More" text at the end
                item.desc = desc.substringWithRange(Range<String.Index>(start: desc.startIndex.advancedBy(1), end: desc.endIndex.advancedBy(-9)))
                
                self.rssData.addObject(item);
                self.reloadData()
                
            }
            print(self.rssData)

        }
    }
    
    func configureTableView() {
        self.rssTableView.registerNib(UINib(nibName: "RSSTableViewCell", bundle:nil), forCellReuseIdentifier: "RSSTableViewCell")
        self.rssTableView.rowHeight = UITableViewAutomaticDimension
        self.rssTableView.estimatedRowHeight = 160.0
        if (self.rssData.count > 0) {
            self.noContentLabel.hidden = true
        }
    }

    //MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureTableView()
        self.parseFeedburnerLink("http://feeds.feedburner.com/TechCrunch/social?fmt=xml")
        self.title = "TechCrunch Social"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Table View Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
        return rssData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item:RSSItem = rssData[indexPath.row] as! RSSItem
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RSSTableViewCell", forIndexPath: indexPath) as! RSSTableViewCell
        
        cell.title.text = item.title
        cell.desc.text = item.desc
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "hh:mm a | MMMM dd YYYY"
        cell.date.text = dateFormat.stringFromDate(item.date)
        
        return cell
    }
    
}

