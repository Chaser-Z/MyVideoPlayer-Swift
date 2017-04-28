//
//  MyPlayerSheetView.swift
//  MyVideoPlayer
//
//  Created by 张海南 on 2017/4/27.
//  Copyright © 2017年 Beijing Han-sky Education Technology Co. All rights reserved.
//

import UIKit

class MyPlayerSheetView: UIView {

    var sheetStateImageView: UIImageView!
    var sheetTimeLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
    }
    fileprivate func createUI() {
        
        self.backgroundColor = UIColor.colorWith(redColor: 100, green: 100, blue: 100, alpha: 0.7)
        
        self.sheetStateImageView = UIImageView(frame: CGRect(x: 54, y: 12, width: 43, height: 25))
        self.sheetStateImageView.image = UIImage(named: "progress_icon_l")
        self.addSubview(self.sheetStateImageView)
        
        self.sheetTimeLabel = UILabel(frame: CGRect(x: 16, y: 49, width: 118, height: 16))
        self.sheetTimeLabel.text = "00:00:00/00:00:00"
        self.sheetTimeLabel.font = UIFont(name: "Arial-BoldItalicMT", size: 12)
        self.sheetTimeLabel.textAlignment = NSTextAlignment.center
        self.sheetTimeLabel.textColor = UIColor.white
        self.addSubview(self.sheetTimeLabel)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
