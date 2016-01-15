//
//  RSSItem.swift
//  techcrunch
//
//  Created by Adela Chang on 2016/01/13.
//  Copyright (c) 2016年 Adela Chang. All rights reserved.
//

import UIKit

class RSSItem: NSObject {

    //assuming that techcrunch will always provide valid input. will have to add handlers if there's possibility of bad data
    var title: String = ""
    var desc: String = ""
    var date: NSDate = NSDate()
    var img: UIImage = UIImage()

}
