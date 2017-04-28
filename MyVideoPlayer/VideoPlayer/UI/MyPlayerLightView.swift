//
//  MyPlayerLightView.swift
//  MyVideoPlayer
//
//  Created by 张海南 on 2017/4/27.
//  Copyright © 2017年 Beijing Han-sky Education Technology Co. All rights reserved.
//

import UIKit

class MyPlayerLightView: UIView {

    var lightBackView: UIView!
    var lightViewArr: Array<UIView>!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func configureUI() {
        
        // 亮度
        let lightLabel = UILabel()
        lightLabel.frame = CGRect(x: 0, y: 0, width: 155, height: 30)
        lightLabel.text = "亮度"
        lightLabel.textColor = UIColor.black
        lightLabel.textAlignment = .center
        self.addSubview(lightLabel)
        // 图片
        let lightImageView = UIImageView()
        lightImageView.frame = CGRect(x: 30, y: 30, width: 95, height: 95)
        lightImageView.image = UIImage(named: "play_new_brightness_day")
        self.addSubview(lightImageView)
        
        
        self.lightBackView = UIView()
        self.lightBackView.frame = CGRect(x: 10, y: 134, width: 135, height: 6)
        self.lightBackView.backgroundColor  = UIColor.lightGray
        self.addSubview(self.lightBackView)
        
        self.lightViewArr = Array()
        self.layer.cornerRadius = 10.0
        let backWidth = self.lightBackView.bounds.size.width
        let backHeight = self.lightBackView.bounds.size.height
        let viewWidth = (backWidth - (16 + 1)) / 16
        let viewHeight = backHeight - 2
        
        for i in 0..<16 {
            
            let view = UIView()
            view.frame = CGRect(x: 1 + CGFloat(i) * (viewWidth + 1), y: 1, width: viewWidth, height: viewHeight)
            view.backgroundColor = UIColor.white
            self.lightViewArr.append(view)
            self.lightBackView.addSubview(view)
        }
    }
    
    func changeLightViewWithValue(_ lightValue: Float) {
        
        let allCount = self.lightViewArr.count
        let lightCount: Float = lightValue * Float(allCount)
        for i in 0..<allCount {
            
            let view = self.lightViewArr[i]
            if Float(i) < lightCount {
                
                view.backgroundColor = UIColor.white
            } else {
                
                view.backgroundColor = UIColor.colorWith(redColor: 65, green: 67, blue: 70, alpha: 1)
            }
            
        }
        
        
    }


}
