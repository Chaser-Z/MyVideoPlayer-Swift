//
//  MySlider.swift
//  MyVideoPlayer
//
//  Created by 张海南 on 2017/4/25.
//  Copyright © 2017年 Beijing Han-sky Education Technology Co. All rights reserved.
//

import UIKit

@objc
protocol MySliderDelegate {
    
    func sliderValueChangeDidBegin(_ slider: MySlider)
    func sliderValueChanged(_ slider: MySlider)
    @objc optional func sliderValueChangeDidEnd(_ slider: MySlider)
    
}

class MySlider: UIControl {

    
    
    /**  UISlider */
    var slider: UISlider!
    /**  UIProgressView */
    var progressView: UIProgressView!
    /** mySliderDelegate */
    var delegate: MySliderDelegate!
    /** 初始值  默认0*/
    var startValue: Float = 0 {
        didSet{
            self.slider.value = startValue
            if startValue > 1 {
                self.slider.value = 1
            }
        }

    }
    /** 缓冲值  默认0*/
    var bufferValue: Float = 0 {
        
        didSet {
            self.progressView.progress = bufferValue
            
            if self.progressView.progress >= 1 {
                
                self.progressView.progress = 1
                
            }
        }
    }
    /** 进度条已经走完的那部分颜色 默认颜色darkGray*/
    var progressTintColor: UIColor = UIColor.darkGray {
        didSet {
            
            self.progressView.progressTintColor = progressTintColor
        }
    }
    /** 进度条没有走完的那部分颜色 默认颜色lightGray*/
    var trackTintColor: UIColor = UIColor.lightGray {
        didSet {
            
            self.progressView.trackTintColor = trackTintColor
        }
    }
    /** 滑动slider走动的图片 */
    var minimumTrackImage: UIImage! {
        didSet {
            
            self.slider.setMinimumTrackImage(minimumTrackImage, for: UIControlState())
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadSubView()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.loadSubView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadSubView() {
        
        self.backgroundColor = UIColor.clear
        
        self.slider = UISlider(frame: CGRect.zero)
        // 初始开始值
        self.slider.value = startValue
        self.slider.autoresizingMask = [UIViewAutoresizing.flexibleWidth,UIViewAutoresizing.flexibleHeight]
        self.slider.alpha = 1

        //self.slider.continuous = false
        self.slider.addTarget(self, action: #selector(MySlider.sliderValueChanged(_:)), for: .valueChanged)
        self.slider.addTarget(self, action: #selector(MySlider.sliderValueChangeDidBegin(_:)), for: .touchDown)
        self.slider.addTarget(self, action: #selector(MySlider.sliderValueChangeDidEnd(_:)), for: .touchUpInside)
        self.slider.addTarget(self, action: #selector(MySlider.sliderValueChangeDidEnd(_:)), for: .touchCancel)
        self.slider.addTarget(self, action: #selector(MySlider.sliderValueChangeDidEnd(_:)), for: .touchUpOutside)
        
        self.progressView = UIProgressView(frame: CGRect.zero)
        self.progressView.autoresizingMask = [UIViewAutoresizing.flexibleWidth,UIViewAutoresizing.flexibleHeight]
        self.progressView.isUserInteractionEnabled = false
        
        // 默认值，可以修改
        // 缓冲开始值
        self.bufferValue = 0
        // slider把圆点设置成图片
        self.setThumbImage(UIImage(named: "bg_slider_nal")!, state: UIControlState())
        self.setThumbImage(UIImage(named: "bg_slider_sel")!, state: .highlighted)
        
        self.minimumTrackImage = UIImage(named: "slider_progress")
        
        self.progressView.progressTintColor = self.progressTintColor
        self.progressView.trackTintColor = self.trackTintColor
        self.slider.maximumTrackTintColor = UIColor.clear

        self.addSubview(self.slider)
        self.slider.addSubview(self.progressView)
        self.slider.sendSubview(toBack: self.progressView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.slider.frame = self.bounds
        var rect = self.slider.bounds
        rect.origin.x = rect.origin.x + 2
        rect.size.width = rect.size.width - 2 * 2
        self.progressView.frame = rect
        self.progressView.center = self.slider.center
    }
    func sliderValueChangeDidBegin(_ slider: UISlider) {
        
        self.delegate.sliderValueChangeDidBegin(self)
    }
    func sliderValueChanged(_ slider: UISlider) {
        
        self.delegate.sliderValueChanged(self)
    }
    func sliderValueChangeDidEnd(_ slider: UISlider) {
        
        self.delegate.sliderValueChangeDidEnd!(self)
        
        
    }
    //MARK: - 设置slider圆点的图片
    func setThumbImage(_ thumbImage: UIImage,state: UIControlState) {
        
        self.slider.setThumbImage(thumbImage, for: state)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("点击")
    }
    
}

/** 扩展 UIImage */
extension UIImage {
    
    class func imageWithColor(_ color: UIColor,size: CGSize) -> UIImage {
        
        var image: UIImage!
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
        
    }
}
