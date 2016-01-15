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
    @IBOutlet weak var img: UIImageView!
    
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

    func parseFeedburnerLink(url:String, completionHandler : ((success : Bool) -> Void)) {

        
        self.rssData = NSMutableArray()
        Alamofire.request(.GET, url, parameters: nil).response { (request, response, data, error) in
            let xml = SWXMLHash.parse(data!)
            
            if (error != nil) {
                completionHandler(success: false)
            }
            
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {

            //assuming an rss item ALWAYS contains valid data. if not must add error handling
                for elem in xml["rss"]["channel"]["item"] {
                
                    //print("Working on thread: \(NSThread.currentThread()) is main thread: \(NSThread.isMainThread())")

                    let imgURL = elem["media:content"][0].element!.attributes["url"]!
                    
                    //parse xml
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "EEE, d MMM YYYY HH:mm:ss +SSSS"
                    let date = dateFormatter.dateFromString(elem["pubDate"].element!.text!)!
                    
                    let desc = elem["description"].element!.text!.stringByDecodingHTMLEntities.stringByStrippingHTMLTags
                    
                    let item = RSSItem()
                    item.title = elem["title"].element!.text!
                    item.date = date
                    
                    item.img = UIImage(data: NSData(contentsOfURL:NSURL(string:imgURL)!)!)!

                    //note: using substring bc techcrunch always has 1 extra space in front of its descriptions, and extraneous "Read More" text at the end
                    item.desc = desc.substringWithRange(Range<String.Index>(start: desc.startIndex.advancedBy(1), end: desc.endIndex.advancedBy(-9)))
                    self.rssData.addObject(item)

                    dispatch_async(dispatch_get_main_queue()) {
                        //print("Back to main thread: \(NSThread.currentThread()) is main thread: \(NSThread.isMainThread())")
                        self.reloadData()

                    }
                }
                
                
            }
            completionHandler(success: true)
            
            

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
        self.parseFeedburnerLink("http://feeds.feedburner.com/TechCrunch/social?fmt=xml", completionHandler: {(success) -> Void in}) //do nothing, this isn't a background fetch
        self.title = "TechCrunch Social"
    }
    
    override func viewWillAppear(animated: Bool) {
        self.configureTableView()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Table View Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
        return self.rssData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let item:RSSItem = self.rssData[indexPath.row] as! RSSItem
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RSSTableViewCell", forIndexPath: indexPath) as! RSSTableViewCell
        
        cell.title.text = item.title
        cell.desc.text = item.desc
        cell.img.image = item.img
        
        if (self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Compact) {

            let aspectRatio = item.img.size.height / item.img.size.width
            
            cell.img.removeConstraints(cell.img.constraints) //clear old constraints from dequeuing the cell
            
            let constraint:NSLayoutConstraint = NSLayoutConstraint(item: cell.img, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: cell.img, attribute: NSLayoutAttribute.Width, multiplier: aspectRatio, constant: 0.0)
            
            cell.img.addConstraint(constraint)
            cell.layoutSubviews()
        }
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "hh:mm a | MMMM dd YYYY"
        cell.date.text = dateFormat.stringFromDate(item.date)

        return cell
    }
    
    //MARK: - Table View Delegate
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewControllerWithIdentifier("RSSDetailViewController") as! RSSDetailViewController
//        vc.item = self.rssData[indexPath.row] as! RSSItem
//
//        self.navigationController?.pushViewController(vc, animated: false)
//
//
//    }
    
}

