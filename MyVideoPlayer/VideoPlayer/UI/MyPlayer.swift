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

    /**  包含在哪一个控制器中 */
    var contrainerViewController: UIViewController!
    fileprivate var coverView: MyPlayerCoverView!
    /**  判断是否是全屏状态 */
    var isFullScreen = false
    // 
    fileprivate var seekStatus: MyPlayerSeekStatus!
    fileprivate var controlType: ControlType!
    fileprivate var playStatus: MyPlayerStatus!
    
    fileprivate var pointX: CGFloat! = 0
    
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

        if self.playerView.playStatus == MyPlayerStatus.playing || self.playerView.playStatus == MyPlayerStatus.readyToPlay{
            
            self.playerView.pausePlay()
        } else {
            self.playerView.goonPlay()
        }
        
        
    }
    // MARK: - MyPlayerLayerViewDelegate
    func layerView(totalDuration: Float, timeInterval: Float) {
        self.coverView.slider.bufferValue = timeInterval / totalDuration
        
    }
    func layerView(playCurrentTime: Float, totalTime: Float) {
        
        if self.seekStatus != MyPlayerSeekStatus.seeking {
            self.coverView.slider.startValue = playCurrentTime / totalTime
            self.coverView.currentTimeLabel.text = timeFormatted(Int(playCurrentTime))
            self.coverView.totalTimeLabel.text = totalTime.isNaN ?  "00:00" : timeFormatted(Int(totalTime))
        }
       
    }
    func layerView(bufferStatusChange bufferStatus: MyPlayerBufferStatus) {
        
        //print("bufferStatus = \(bufferStatus)")
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
        } else if self.playStatus == MyPlayerStatus.playing {
            self.coverView.startAndStopButton.isSelected = false
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
            print("back")
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
    // MARK: - 切换播放
    func changePlay(palyUrl url: String, title: String) {
        self.playerView.changeToPlay(palyUrl: url)
    }
    // MARK: - 销毁播放器
    func prepareToDealloc() {
        self.playerView.prepareToDeinit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
