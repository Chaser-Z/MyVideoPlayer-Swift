//
//  MyPlayerLayerView.swift
//  MyVideoPlayer
//
//  Created by 张海南 on 2017/4/25.
//  Copyright © 2017年 Beijing Han-sky Education Technology Co. All rights reserved.
//

import UIKit
import MediaPlayer
import SnapKit

protocol MyPlayerLayerViewDelegate {
    
    func layerView(totalDuration: Float, timeInterval: Float)
    func layerView(playCurrentTime: Float, totalTime: Float)
    func layerView(bufferStatusChange bufferStatus: MyPlayerBufferStatus)
    func layerView(playStatusChange playStatus: MyPlayerStatus)
    
}


class MyPlayerLayerView: UIView {

    fileprivate var items: Array<AVPlayerItem>! = Array()

    var urls: Array<String>!
    var urlString: String!
    var player: AVQueuePlayer!
    var playerLayer: AVPlayerLayer!
    var currentItem: AVPlayerItem!
    var bgImageView: UIImageView!
    var duration: Float!
    var currentTime: Float!
    var playStatus: MyPlayerStatus! = MyPlayerStatus.none
    fileprivate var bufferStatus = MyPlayerBufferStatus.none {
        didSet {
            delegate.layerView(bufferStatusChange: bufferStatus)
        }
    }
    var delegate: MyPlayerLayerViewDelegate!
    // 计时器
    fileprivate var playTime: Timer!
    
    init(frame: CGRect, urlString: String) {
    //init(frame: CGRect, urls: Array<String>) {
        super.init(frame: frame)
        //self.urls = urls
        self.urlString = urlString
        self.createPlayer()
        self.configureUI()
    }
    fileprivate func createPlayer() {
//        self.urls.forEach {
//             items.append(AVPlayerItem(url: URL(string: $0)!))
//        }
//        self.player = AVQueuePlayer(items: items)
        self.player = AVQueuePlayer()
    }
    fileprivate func configureUI() {
        
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.red
        // 背景图片
        self.bgImageView = UIImageView(frame: self.bounds)
        self.bgImageView.image = UIImage(named: "bg_media_default.jpg")
        self.addSubview(self.bgImageView)
        self.playerLayer = AVPlayerLayer(player: self.player)
        // 填充视频
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.bgImageView.layer.addSublayer(self.playerLayer)
    }
    fileprivate func configureTimer() {
        
        if self.playTime != nil {
            self.playTime.invalidate()
        }
        self.playTime = Timer(timeInterval: 0.5, target: self, selector: #selector(MyPlayerLayerView.playerTimerAction), userInfo: nil, repeats: true)
        self.playTime.fireDate = Date()
        RunLoop.main.add(self.playTime!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    // MARK: - 计时器事件
    @objc fileprivate func playerTimerAction() {
        let currentTime = CMTimeGetSeconds(self.player!.currentTime())
        self.currentTime = Float(currentTime)
        let totalTime = Float(self.currentItem.duration.value) / Float(self.currentItem.duration.timescale)
        self.delegate.layerView(playCurrentTime: Float(currentTime), totalTime: Float(totalTime))
    
        self.updateStatus(inclodeLoading: true)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - 开始播放
    func startPlay() {
       
        let url = URL(string: self.urlString)
        //let url = URL(string: self.urls[0])
        let item = AVPlayerItem(url: url!)
        self.currentItem = item
        self.player.replaceCurrentItem(with: self.currentItem)
        self.player.play()
        self.playStatus = .playing
        self.configureTimer()
        self.addNotic()
    }
    // MARK: - 暂停播放
    func pausePlay() {
        self.player.pause()
        self.playStatus = .pause
        self.playTime.fireDate = Date.distantFuture
    }
    // MARK: - 继续播放
    func goonPlay() {
        
        self.player.play()
        self.playStatus = .playing
        self.playTime.fireDate = Date()
        
    }
    // MARK: - 播放完毕
    @objc fileprivate func playEnd(_ sender: AnyObject) {
        
        print("播放结束")
        self.playTime.invalidate()
        self.playStatus = .end
        self.player.pause()
        self.delegate.layerView(playStatusChange: self.playStatus)
    }
    //MARK: - 进入前后台通知
    @objc fileprivate func resignActiveNotification(_ notic:AnyObject) {
        print("进入后台")
        
    }
    @objc fileprivate func becomeActiveNotification(_ notic: AnyObject) {
        print("返回前台")
    }
    // MARK: - KVO(监控视频各种状态)
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
       
        if let item = self.currentItem {
            if self.player == nil {
                return
            }
            if keyPath == "loadedTimeRanges" {
                // 计算缓冲进度
                let timeInterval = self.availableDuration()
                // 计算总播放时间
                let duration = self.currentItem.duration
                let totalDuration = CMTimeGetSeconds(duration)
                self.duration = Float(totalDuration)
                // 显示缓冲进度
                self.delegate.layerView(totalDuration: Float(totalDuration), timeInterval: timeInterval)
                
                
            } else if keyPath == "playbackBufferEmpty" {
                print("playbackBufferEmpty")
                // 缓冲是空
                if item.isPlaybackBufferEmpty {
                    self.bufferStatus = .buffering
                    self.bufferingSomeSecond()
                }
                
            } else if keyPath == "playbackLikelyToKeepUp" {
                print("playbackLikelyToKeepUp")
                if let item = object as? AVPlayerItem {
                    if item.isPlaybackBufferEmpty && self.bufferStatus != .bufferFinished{
                        self.bufferStatus = .bufferFinished
                    }
                }
                
            } else if keyPath == "status" {
                
                switch self.player.status {
                case .failed:
                    self.playStatus = .failed
                case .readyToPlay:
                    self.playStatus = .readyToPlay
                case .unknown:
                    self.playStatus = .unknown
                    
                }
                
            } else if keyPath == "rate" {
                
                self.updateStatus()
                
            }

        }
        
    }
    fileprivate func updateStatus(inclodeLoading: Bool = false){
        
        if let player = player {
            if let playerItem = self.currentItem {
                if inclodeLoading {
                    if playerItem.isPlaybackLikelyToKeepUp || playerItem.isPlaybackBufferFull {
                        self.bufferStatus = .bufferFinished
                    } else {
                        self.bufferStatus = .buffering
                    }
                }
            }
            if player.rate == 0.0 {
                if player.error != nil {
                    self.bufferStatus = .error
                    return
                }
                if let currentItem = player.currentItem {
                    if player.currentTime() >= currentItem.duration {
                        print("播放结束")
                        return
                    }
                    if currentItem.isPlaybackLikelyToKeepUp || currentItem.isPlaybackBufferFull {
                        
                    }
                }
            }
        }

    }
    // 缓冲进度
    fileprivate func availableDuration() -> Float {
        
        let ranges = self.player.currentItem?.loadedTimeRanges
        // 获取缓冲区域
        let timeRange = ranges?.first?.timeRangeValue
        let startSeconds = CMTimeGetSeconds((timeRange?.start)!)
        let durationSeconds = CMTimeGetSeconds((timeRange?.duration)!)
        // 计算缓冲进度
        let result = Float(startSeconds + durationSeconds)
        return result
        
    }
    // 缓冲比较差的时候
    fileprivate func bufferingSomeSecond() {
        
        self.bufferStatus = .buffering
        // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
        self.player.pause()
        self.playStatus = .pause
        print("暂停暂停暂停暂停暂停暂停暂停暂停暂停暂停暂停")
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * 1.0 )) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: popTime) { 
            
            if let item = self.currentItem {
                // item.isPlaybackLikelyToKeepUp为no,需要再缓冲一会
                if !item.isPlaybackLikelyToKeepUp {
                    
                    self.bufferingSomeSecond()
                    
                } else {
                    self.bufferStatus = .bufferFinished
                    
                }
                
            }
            
        }
        
        
    }
    // MARK: - 切换播放
    func changeToPlay(palyUrl url: String) {
        //self.player.pause()
        self.removeNotic()
        //self.player.advanceToNextItem()
        self.currentItem = AVPlayerItem(url: NSURL(string: url)! as URL)
        self.player = AVQueuePlayer(playerItem: self.currentItem)
        self.addNotic()
        self.playerLayer.removeFromSuperlayer()
        self.playerLayer = AVPlayerLayer(player: player)
        self.bgImageView.layer.addSublayer(self.playerLayer)
        self.player.play()
        self.configureTimer()
        self.playStatus = .playing
        self.delegate.layerView(playStatusChange: .playing)
        setNeedsLayout()
        layoutIfNeeded()
    }
    // MARK: - 销毁播放器
    func prepareToDeinit() {
        // 初始化状态变量
        self.pausePlay()
        self.playTime.invalidate()
        // 移除原来的layer
        self.playerLayer?.removeFromSuperlayer()
        // 替换PlayerItem为nil
        self.player?.replaceCurrentItem(with: nil)
        // 移除通知
        self.removeNotic()
        // 把player置为nil
        self.player = nil
    }
    
    // MARK: - 添加通知
    fileprivate func addNotic() {
    
        if let item = self.currentItem {
            
            // 播放结束通知
            NotificationCenter.default.addObserver(self, selector: #selector(MyPlayerLayerView.playEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(MyPlayerLayerView.resignActiveNotification(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(MyPlayerLayerView.becomeActiveNotification(_:)), name:NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
            
            // status属性，通过监控它的status也可以获得播放状态
            item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
            // 缓冲区空了，需要等待数据
            item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
            // 缓冲区有足够数据可以播放了
            item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
            self.player!.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)

        }
    }
    // MARK: - 移除通知
    fileprivate func removeNotic() {
        
        if let item = self.currentItem {
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
            NotificationCenter.default.removeObserver(self)

            item.removeObserver(self, forKeyPath: "status")
            item.removeObserver(self, forKeyPath: "loadedTimeRanges")
            item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")

        }
        self.player.removeObserver(self, forKeyPath: "rate")

        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        insertSubview(self.bgImageView!, at: 0)
        self.bgImageView.frame = self.bounds
        self.playerLayer.frame = self.bounds
    }
    

}
