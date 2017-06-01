//
//  MyPlayer.swift
//  MyVideoPlayer
//
//  Created by 张海南 on 2017/4/25.
//  Copyright © 2017年 Beijing Han-sky Education Technology Co. All rights reserved.
//

import UIKit
import SnapKit
import MediaPlayer


class MyPlayer: UIView, MyPlayCoverViewDelegate, MyPlayerLayerViewDelegate {

    fileprivate var playerView: MyPlayerLayerView!
    fileprivate var isHaveSelected = false
    fileprivate var currentURL: String!
    
    var subtitle = GetPlayResource()


    /**  包含在哪一个控制器中 */
    var contrainerViewController: UIViewController!
    fileprivate var coverView: MyPlayerCoverView!
    /**  判断是否是全屏状态 */
    var isFullScreen = false
    // 
    fileprivate var seekStatus: MyPlayerSeekStatus!
    fileprivate var controlType: ControlType!
    fileprivate var playStatus: MyPlayerStatus!
    
    init(frame: CGRect, urlString: String, title: String) {
    //init(frame: CGRect, urls: Array<String>, title: String) {
        super.init(frame: frame)
        self.play(urlString: urlString)
        //self.play(urls: urls)
        self.createCoverView(title: title)
        self.seekStatus = MyPlayerSeekStatus.none
        self.controlType = ControlType.noneControl
        // 屏幕转动通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChanged), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    fileprivate func play(urlString: String) {
    //fileprivate func play(urls: Array<String>) {
        self.playerView = MyPlayerLayerView(frame: CGRect.zero, urlString: urlString)
        //self.playerView = MyPlayerLayerView(frame: CGRect.zero, urls: urls)
        self.currentURL = urlString
        self.playerView.startPlay()
        self.playerView.delegate = self
        self.addSubview(self.playerView)
        playerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    fileprivate func createCoverView(title: String) {
        
        self.coverView = MyPlayerCoverView()
        self.coverView.delegate = self
        self.coverView.titleLabel.text = title
        self.addSubview(self.coverView)
        self.coverView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
    }

    // MARK: - 屏幕旋转通知
    @objc fileprivate func onOrientationChanged() {
        //self.updateUI(isFullScreen)
    }
    // MARK: - buttonAction
    // 全屏按钮点击事件
    @objc fileprivate func fullScreenButtonClick() {
        if isFullScreen {
            self.isFullScreen = false
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
            UIApplication.shared.statusBarOrientation = .portrait
        } else {
            self.isFullScreen = true
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
            UIApplication.shared.statusBarOrientation = .landscapeRight
        }
        
    }
    // 播放和暂停按钮
    fileprivate func stopAndPlayButtonClick() {

        print(self.playerView.playStatus)
        if (self.playerView.playStatus == MyPlayerStatus.playing || self.playerView.playStatus == MyPlayerStatus.readyToPlay) && self.isHaveSelected == false{
            
            self.playerView.pausePlay()
        } else {
            self.playerView.goonPlay()
        }
        
        
    }
    // 返回按钮
    fileprivate func backButtonClick() {
        if isFullScreen == true {
            self.fullScreenButtonClick()
        } else {
            self.contrainerViewController.navigationController?.popViewController(animated: true)
        }
        
    }
    // MARK: - MyPlayerLayerViewDelegate
    func layerView(totalDuration: Float, timeInterval: Float) {
        self.coverView.slider.bufferValue = timeInterval / totalDuration
        
    }
    func layerView(playCurrentTime: Float, totalTime: Float) {
        
        if self.seekStatus != MyPlayerSeekStatus.seeking {
            self.coverView.slider.startValue = playCurrentTime / totalTime
            self.coverView.currentTimeLabel.text = playCurrentTime.isNaN ? "00:00" : timeFormatted(Int(playCurrentTime))
            self.coverView.totalTimeLabel.text = totalTime.isNaN ?  "00:00" : timeFormatted(Int(totalTime))
        }
        if !totalTime.isNaN {
            
            self.coverView.showSubtile(from: subtitle!, at: TimeInterval(playCurrentTime))

        }
    }
    func layerView(bufferStatusChange bufferStatus: MyPlayerBufferStatus) {
        if bufferStatus == .buffering {
            self.coverView.showLoader()
            //self.playerView.pausePlay()
        } else {
            self.coverView.hideLoader()
            self.playerView.goonPlay()
        }
        
    }
    func layerView(playStatusChange playStatus: MyPlayerStatus) {
        self.playStatus = playStatus
        if self.playStatus == MyPlayerStatus.end {
            self.coverView.startAndStopButton.isSelected = true
            self.coverView.replayButton.isHidden = false
        } else if self.playStatus == MyPlayerStatus.playing {
            self.coverView.startAndStopButton.isSelected = false
            self.coverView.replayButton.isHidden = true
        }
    }
    func layerView(isBecomeActiveNotification isB: Bool) {
        if isB == true {
            if isHaveSelected == true{
                
            } else {
                self.playerView.goonPlay()
                self.coverView.startAndStopButton.isSelected = false
                self.isHaveSelected = false
            }
        } else {
            if self.coverView.startAndStopButton.isSelected == true {
                isHaveSelected = true
            }
            self.coverView.startAndStopButton.isSelected = true
            self.playerView.pausePlay()
        }
    }
    //MARK: - 转换时间（00:00）
    fileprivate func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - MyPlayCoverViewDelegate
    func coverViewButtonAction(coverButton: UIButton) {
    
        switch coverButton.tag {
        case 100:
            self.fullScreenButtonClick()
        case 101:
            self.stopAndPlayButtonClick()
        case 102:
            self.backButtonClick()
        case 103:
            self.seek(0)
            self.playerView.changeToPlay(palyUrl: self.currentURL)
        default:
            print("1")
        }
    }
    func coverViewSilderVauleChange(_ slider: MySlider, seekStatus: MyPlayerSeekStatus, controlType: ControlType, tempPoint: CGPoint?, touchBeginPoint: CGPoint?, isLeftMove: Bool) {
        self.seekStatus = seekStatus
        self.controlType = controlType
        // silder
        if self.controlType == ControlType.noneControl && tempPoint == nil && self.playerView.duration != nil {
            
            let progress = self.playerView.duration * slider.slider.value
            if seekStatus == .seeking{
                self.coverView.currentTimeLabel.text = timeFormatted(Int(progress))
            } else if seekStatus == .end{
                // 播放到
                let cmTime = CMTimeMake(Int64(progress), 1)
                self.playerView.player.seek(to: cmTime)
            }
        }
        // 左右滑动
        if self.controlType == ControlType.progressControl && touchBeginPoint != nil && self.playerView.duration != nil{
            
            let value = self.moveProgressControllWithTempPoint(tempPoint!, touchBeginPoint: touchBeginPoint!)
            if value.isNaN {
                return
            }
            if seekStatus == .seeking {
                self.coverView.currentTimeLabel.text = self.timeFormatted(Int(value))
                self.coverView.slider.startValue = Float(value) / Float(self.playerView.duration)
            } else if seekStatus == .end {
                // 播放到
                let cmTime = CMTimeMake(Int64(value), 1)
                self.playerView.player.seek(to: cmTime)
                self.playerView.currentTime = self.moveProgressControllWithTempPoint(tempPoint!, touchBeginPoint: touchBeginPoint!)
            }
            
            // 处理sheetView
            if isLeftMove == false {
                self.coverView.timeView.sheetStateImageView.image = UIImage(named: "progress_icon_r")
            } else {
                self.coverView.timeView.sheetStateImageView.image = UIImage(named: "progress_icon_l")
            }
            self.coverView.timeView.isHidden = false
            let tempTime = self.timeFormatted(Int(value))
            let totalTime = self.timeFormatted(Int(self.playerView.duration))
            self.coverView.timeView.sheetTimeLabel.text = String(format: "%@/%@", tempTime,totalTime)
        }
        
    }
    // MARK: - 用来控制移动过程中计算手指划过的时间
    fileprivate func moveProgressControllWithTempPoint(_ tempPoint: CGPoint, touchBeginPoint: CGPoint) -> Float {
        
        var tempVaule: Float = self.playerView.currentTime + 90 * Float((tempPoint.x - touchBeginPoint.x) / SCREENW)
        if tempVaule >= self.playerView.duration {
            tempVaule = self.playerView.duration
        } else if tempVaule <= 0 {
            tempVaule = 0.0
        }
        return tempVaule
    }
    // MARK: - seek
    func seek(_ to:TimeInterval, completion: (()->Void)? = nil) {
        self.playerView.seek(to: to, completion: completion)
    }

    // MARK: - 切换播放
    func changePlay(palyUrl url: String, title: String) {
        self.playerView.changeToPlay(palyUrl: url)
        self.currentURL = url
    }
    // MARK: - 销毁播放器
    func prepareToDealloc() {
        self.playerView.prepareToDeinit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
