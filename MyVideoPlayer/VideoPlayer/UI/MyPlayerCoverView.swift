//
//  MyPlayerCoverView.swift
//  MyVideoPlayer
//
//  Created by 张海南 on 2017/4/26.
//  Copyright © 2017年 Beijing Han-sky Education Technology Co. All rights reserved.
//

import UIKit
import SnapKit
import MediaPlayer
import NVActivityIndicatorView
let iOS8 = (UIDevice.current.systemVersion as NSString).floatValue >= 8.0


protocol MyPlayCoverViewDelegate {
    
    func coverViewButtonAction(coverButton: UIButton)
    /**
     * seekStatus        - 拖动siler的状态
     * controlType       - 滑动屏幕是的状态
     * tempPoint         - 滑动的点
     * touchBeginPoint   — 滑动开始的点
     * isLeftMove        - 判断左右滑动方向
     */
    func coverViewSilderVauleChange(_ slider: MySlider,seekStatus: MyPlayerSeekStatus,controlType: ControlType, tempPoint: CGPoint?, touchBeginPoint: CGPoint?, isLeftMove: Bool)
}

class MyPlayerCoverView: UIView,MySliderDelegate {

    // 顶部View
    fileprivate var topView: UIView!
    // title
    var titleLabel: UILabel!
    // 返回按钮
    fileprivate var backButton: UIButton!
    // 分享按钮
    fileprivate var shareButton: UIButton!
    
    // 底部View
    fileprivate var bottomView: UIView!
    /**  播放进度slider */
    var slider: MySlider!
    // 全屏按钮
    fileprivate var fullButton: UIButton!
    // 开始暂停按钮
    var startAndStopButton: UIButton!
    // 播放现在的时间
    var currentTimeLabel: UILabel!
    // 播放总的时间
    var totalTimeLabel: UILabel!
    
    // 音量控制控件
    fileprivate var volumeView: MPVolumeView!
    fileprivate var volumeSlider: UISlider!
    /** 记录触摸开始的音量 */
    fileprivate var touchBeginVoiceValue: Float!
    
    
    // 亮度View
    fileprivate var lightView: MyPlayerLightView!
    fileprivate var touchBeginLightValue: CGFloat!
    fileprivate var effectView: UIVisualEffectView!
    
    /**  触摸开始触碰到的点 */
    fileprivate var touchBeginPoint: CGPoint!

    /**  屏幕中间的滑动时间显示的view */
    var timeView: MyPlayerSheetView!
    
    // 等待提醒试图
    fileprivate var loadingIndector  = NVActivityIndicatorView(frame:  CGRect(x: 0, y: 0, width: 30, height: 30))

    // enum
    fileprivate var controlType: ControlType!
    fileprivate var seekStatus: MyPlayerSeekStatus!
    var delegate: MyPlayCoverViewDelegate!


    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.controlType = ControlType.noneControl
        self.setupUI()
        self.addSnapKitConstraint()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupUI() {
        
        self.createVolumeView()
        self.createLightView()
        self.createTimeView()
        self.createTopView()
        self.createBottomView()
        self.createMySlider()
        self.createButton()
        self.createLabel()
        
    }
    // MARK: - View
    fileprivate func createVolumeView() {
        self.volumeView = MPVolumeView()
        self.volumeView.showsRouteButton = false
        self.volumeView.showsVolumeSlider = false
        for view in self.volumeView.subviews {
            if NSStringFromClass(view.classForCoder) == "MPVolumeSlider" {
                self.volumeSlider = view as? UISlider
                break
            }
        }
        self.addSubview(self.volumeView)
        
    }
    fileprivate func createLightView() {
        
        if iOS8 {
            
            self.effectView = UIVisualEffectView()
            UIView.animate(withDuration: 0.5, animations: {
                let blur: UIBlurEffect = UIBlurEffect(style: .extraLight)
                self.effectView = UIVisualEffectView(effect: blur)
            })
            self.effectView.alpha = 0
            self.effectView.contentView.layer.cornerRadius = 10.0
            self.effectView.layer.masksToBounds = true
            self.effectView.layer.cornerRadius = 10.0
            
            self.lightView = MyPlayerLightView()
            self.lightView.translatesAutoresizingMaskIntoConstraints = false
            self.lightView.alpha = 0
            self.effectView.contentView.addSubview(self.lightView)
            self.addSubview(self.effectView)
            
        } else {
            self.lightView = MyPlayerLightView()
            self.lightView.translatesAutoresizingMaskIntoConstraints = false
            self.lightView.alpha = 0
            self.addSubview(self.lightView)

        }
        
    }
    fileprivate func createTimeView(){
        self.timeView = MyPlayerSheetView()
        self.timeView.layer.cornerRadius = 10.0
        self.timeView.isHidden = true
        self.addSubview(self.timeView)
    }
    fileprivate func createTopView() {
        
        self.topView = UIView()
        //self.topView.backgroundColor = UIColor.brown
        self.addSubview(self.topView)
    }
    fileprivate func createBottomView() {
        self.bottomView = UIView()
        //self.bottomView.backgroundColor = UIColor.red
        self.addSubview(self.bottomView)
    }
    // MARK: - slider
    fileprivate func createMySlider() {
        
        self.slider = MySlider()
        self.slider.delegate = self
        self.bottomView.addSubview(self.slider)
        
    }
    // MARK: - button
    fileprivate func createButton() {
        
        // 上面button
        self.backButton = UIButton()
        self.backButton.setImage(UIImage(named: "btn_back_click"), for: .normal)
        self.backButton.addTarget(self, action: #selector(MyPlayerCoverView.fullScreenButtonClick), for: .touchUpInside)
        self.backButton.tag = 102
        self.topView.addSubview(self.backButton)
        
        self.shareButton = UIButton()
        self.shareButton.setImage(UIImage(named: "btn_vdo_full"), for: .normal)
        self.shareButton.addTarget(self, action: #selector(MyPlayerCoverView.fullScreenButtonClick), for: .touchUpInside)
        self.shareButton.tag = 103
        self.topView.addSubview(self.shareButton)

        
        // 下面button
        self.fullButton = UIButton()
        self.fullButton.backgroundColor = UIColor.clear
        self.fullButton.setImage(UIImage(named: "btn_vdo_full"), for: .normal)
        self.fullButton.addTarget(self, action: #selector(MyPlayerCoverView.fullScreenButtonClick), for: .touchUpInside)
        self.fullButton.tag = 100
        self.bottomView.addSubview(self.fullButton)
        
        self.startAndStopButton = UIButton()
        self.startAndStopButton.setImage(UIImage(named: "full_pause_btn"), for: .normal)
        self.startAndStopButton.setImage(UIImage(named: "full_play_btn"), for: .selected)
        self.startAndStopButton.isSelected = false
        self.startAndStopButton.addTarget(self, action: #selector(MyPlayerCoverView.fullScreenButtonClick), for: .touchUpInside)
        self.startAndStopButton.tag = 101
        self.bottomView.addSubview(self.startAndStopButton)
        
    }
    // MARK: - label
    fileprivate func createLabel() {
        
        // 上面lable
        self.titleLabel = UILabel()
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont.systemFont(ofSize: 12)
        self.topView.addSubview(self.titleLabel)
        
        // 下面lable
        self.currentTimeLabel = UILabel()
        self.currentTimeLabel.textColor = UIColor.white
        self.currentTimeLabel.textAlignment = .center
        self.currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        self.bottomView.addSubview(self.currentTimeLabel)
        
        self.totalTimeLabel = UILabel()
        self.totalTimeLabel.textColor = UIColor.white
        self.totalTimeLabel.textAlignment = .center
        self.totalTimeLabel.font = UIFont.systemFont(ofSize: 12)
        self.bottomView.addSubview(self.totalTimeLabel)

        
    }
    // MARK: - action
    @objc func fullScreenButtonClick(btn: UIButton) {
        print("fullScreenButtonClick\(btn.tag)")
        btn.isSelected = !btn.isSelected
        delegate.coverViewButtonAction(coverButton: btn)
    }
    // MARK: - IndicatorView
    func showLoader() {
        self.loadingIndector.isHidden = false
        self.loadingIndector.startAnimating()
    }
    func hideLoader() {
        self.loadingIndector.isHidden = true
    }
    // MARK: - 用来控制显示亮度的view, 以及毛玻璃效果的view
    fileprivate func hideTheLightViewWithHidden(_ hidden: Bool) {
        
        if hidden {
            UIView.animate(withDuration: 1.0, delay: 1.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                self.lightView.alpha = 0.0
                if iOS8 {
                    self.effectView.alpha = 0.0
                }
            }, completion: nil)
        } else {
            self.alpha = 1.0
            if iOS8 {
                self.lightView.alpha = 1.0
                self.effectView.alpha = 1.0
            }
        }
        
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.bringLightViewToFront()
    }
    fileprivate func bringLightViewToFront() {
        if iOS8 {
            self.bringSubview(toFront: self.effectView)
        } else {
            self.addSubview(self.lightView)
        }
    }

    // MARK: - Snap
    fileprivate func addSnapKitConstraint() {
        
        if iOS8 {
            self.effectView.snp.makeConstraints({ (make) in
                make.center.equalTo(self.effectView.superview!)
                make.width.equalTo(155)
                make.height.equalTo(155)
            })
            self.lightView.snp.makeConstraints({ (make) in
                make.edges.equalTo(self.effectView)
            })

        } else {
            
            self.lightView.snp.makeConstraints({ (make) in
                make.center.equalTo(self)
                make.width.equalTo(155)
                make.height.equalTo(155)
            })
        }
        
        self.timeView.snp.makeConstraints { (make) in
            make.width.equalTo(150)
            make.height.equalTo(70)
            make.center.equalTo(self)
        }
        
        
        self.bottomView.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
            make.height.equalTo(40)
        }
        
        self.startAndStopButton.snp.makeConstraints { (make) in
            
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.left.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(0)
        }
        self.currentTimeLabel.snp.makeConstraints { (make) in
            
            make.width.equalTo(40)
            make.height.equalTo(20)
            make.left.equalTo(self.startAndStopButton.snp.right).offset(-10)
            make.bottom.equalTo(self).offset(-10)
        }
        
        self.fullButton.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.right.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(0)
            
        }

        self.totalTimeLabel.snp.makeConstraints { (make) in
            
            make.width.equalTo(40)
            make.height.equalTo(20)
            make.right.equalTo(self.fullButton.snp.left).offset(0)
            make.bottom.equalTo(self).offset(-10)
        }

        
        self.slider.snp.makeConstraints { (make) in
            
            make.height.equalTo(10)
            make.left.equalTo(self.currentTimeLabel.snp.right).offset(10)
            make.right.equalTo(self.totalTimeLabel.snp.left).offset(-10)
            make.bottom.equalTo(self).offset(-15)
            
        }
        
        self.topView.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.height.equalTo(60)
        }
        
        self.backButton.snp.makeConstraints { (make) in
            
            make.left.equalTo(self)
            make.top.equalTo(self).offset(20)
            make.height.equalTo(40)
            make.width.equalTo(40)
            
        }
        self.titleLabel.snp.makeConstraints { (make) in
            
            make.left.equalTo(self.backButton).offset(10)
            make.top.equalTo(self).offset(30)
            make.height.equalTo(20)
            make.width.equalTo(100)
            
        }

        self.addSubview(self.loadingIndector)
        loadingIndector.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX).offset(0)
            make.centerY.equalTo(self.snp.centerY).offset(0)
        }

    }
    // MARK: - MySliderDelegate
    func sliderValueChanged(_ slider: MySlider) {
        self.seekStatus = MyPlayerSeekStatus.seeking
        delegate.coverViewSilderVauleChange(slider, seekStatus: .seeking, controlType: .noneControl, tempPoint: nil, touchBeginPoint: nil, isLeftMove: false)
    }
    func sliderValueChangeDidBegin(_ slider: MySlider) {
        
        //delegate.coverViewSilderVauleChange(slider, seekStatus: .seeking)
        
    }
    func sliderValueChangeDidEnd(_ slider: MySlider) {
        self.seekStatus = MyPlayerSeekStatus.end
        delegate.coverViewSilderVauleChange(slider, seekStatus: .end, controlType: .noneControl, tempPoint: nil, touchBeginPoint: nil, isLeftMove: false)
        
    }
    
    // MARK: - touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //print("touchesBegan")
        self.seekStatus = MyPlayerSeekStatus.seeking
        self.touchBeginPoint = ((touches as NSSet).anyObject() as AnyObject).location(in: self)
        self.touchBeginVoiceValue = self.volumeSlider.value
        self.touchBeginLightValue = UIScreen.main.brightness

    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        //print("touchesMoved")
        let tempPoint = ((touches as NSSet).anyObject() as AnyObject).location(in: self)
        // 前一个点
        let prePoint = ((touches as NSSet).anyObject() as AnyObject).previousLocation(in: self)
        // 如果移动的距离过于小, 就判断为没有移动
        if (fabs((tempPoint.x) - self.touchBeginPoint.x) < 15) && (fabs((tempPoint.y) - self.touchBeginPoint.y) < 15) {
            //print("移动距离过小")
            return
        } else {
            // 判断左滑还是右滑
            var isLeftMove = false
            if prePoint.x - tempPoint.x > 0{
                isLeftMove = true
            } else {
                isLeftMove = false
            }
            let tan = fabs(tempPoint.y - self.touchBeginPoint.y) / fabs(tempPoint.x - self.touchBeginPoint.x)
            // 当滑动角度小于30度的时候, 进度手势
            if tan < 1 / sqrt(3) { // 进度
                self.controlType = ControlType.progressControl
                delegate.coverViewSilderVauleChange(slider, seekStatus: .seeking, controlType: .progressControl, tempPoint: tempPoint, touchBeginPoint: self.touchBeginPoint, isLeftMove: isLeftMove)
            } else if tan > 1 / sqrt(3) {
                if self.seekStatus == MyPlayerSeekStatus.seeking && self.controlType == ControlType.progressControl{
                    return
                }
                if  self.touchBeginPoint.x < self.bounds.size.width / 2  { // 亮度
                    self.controlType = ControlType.lightControl
                    self.hideTheLightViewWithHidden(false)
                    var tempLightValue = self.touchBeginLightValue - ((tempPoint.y - self.touchBeginPoint.y)/self.bounds.size.height)
                    if tempLightValue < 0 {
                        tempLightValue = 0
                    } else if tempLightValue > 1 {
                        tempLightValue = 1
                    }
                    // 控制亮度的方法
                    UIScreen.main.brightness = tempLightValue
                    // 实时改变现实亮度进度的view
                    self.lightView.changeLightViewWithValue(Float(tempLightValue))
                    
                } else { // 声音
                    self.controlType = ControlType.voiceControl
                    let voiceValue = self.touchBeginVoiceValue - Float((tempPoint.y - self.touchBeginPoint.y)/self.bounds.size.height)
                    if voiceValue < 0 {
                        self.volumeSlider.value = 0
                    } else if voiceValue > 1 {
                        self.volumeSlider.value = 1
                    } else {
                        self.volumeSlider.value = voiceValue
                    }
                }
            } else {
                
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        //print("touchesEnded")
        self.seekStatus = MyPlayerSeekStatus.end
        let tempPoint = ((touches as NSSet).anyObject() as AnyObject).location(in: self)
        if self.controlType == ControlType.progressControl {
            delegate.coverViewSilderVauleChange(slider, seekStatus: .end, controlType: .progressControl, tempPoint: tempPoint, touchBeginPoint: self.touchBeginPoint, isLeftMove: false)

        }
        self.controlType = ControlType.noneControl
        self.hideTheLightViewWithHidden(true)
        self.timeView.isHidden = true

    }
    

}
