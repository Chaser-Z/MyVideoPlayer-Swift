//
//  PlayViewController.swift
//  MyVideoPlayer
//
//  Created by 张海南 on 2017/4/28.
//  Copyright © 2017年 Beijing Han-sky Education Technology Co. All rights reserved.
//

import UIKit

let SCREENW = UIScreen.main.bounds.width
let SCREENH = UIScreen.main.bounds.height
class PlayViewController: UIViewController {

    var player: MyPlayer!
    var changeButton = UIButton()
    let urls = ["http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4",
                "http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                "http://baobab.wdjcdn.com/14525705791193.mp4",
                "http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                "http://baobab.wdjcdn.com/1455968234865481297704.mp4",
                "http://baobab.wdjcdn.com/1455782903700jy.mp4",
                "http://baobab.wdjcdn.com/14564977406580.mp4",
                "http://baobab.wdjcdn.com/1456316686552The.mp4",
                "http://baobab.wdjcdn.com/1456480115661mtl.mp4",
                "http://baobab.wdjcdn.com/1456665467509qingshu.mp4",
                "http://baobab.wdjcdn.com/1455614108256t(2).mp4",
                "http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4",
                "http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",
                "http://baobab.wdjcdn.com/1456734464766B(13).mp4",
                "http://baobab.wdjcdn.com/1456653443902B.mp4",
                "http://baobab.wdjcdn.com/1456231710844S(24).mp4"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = UIColor.white
        self.player = MyPlayer(frame: CGRect.zero, urlString: "http://baobab.wdjcdn.com/1455782903700jy.mp4", title: "测试")
        self.player.contrainerViewController = self
        self.view.addSubview(self.player)
        
        player.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(view.snp.width).multipliedBy(9.0/16.0)
        }
        
        let qe: DispatchQoS = DispatchQoS(qosClass: .default, relativePriority: 0)
        DispatchQueue.global(qos: qe.qosClass).async {
            
        }
        
        
        changeButton.setTitle("Change Video", for: .normal)
        changeButton.addTarget(self, action: #selector(onChangeVideoButtonPressed), for: .touchUpInside)
        changeButton.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        view.addSubview(changeButton)
        
        changeButton.snp.makeConstraints { (make) in
            make.top.equalTo(player.snp.bottom).offset(30)
            make.left.equalTo(view.snp.left).offset(10)
        }
        changeButton.isHidden = false
        self.view.layoutIfNeeded()
    }
    @objc fileprivate func onChangeVideoButtonPressed() {
        let urls = ["http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4",
                    "http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                    "http://baobab.wdjcdn.com/14525705791193.mp4",
                    "http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                    "http://baobab.wdjcdn.com/1455968234865481297704.mp4",
                    "http://baobab.wdjcdn.com/1455782903700jy.mp4",
                    "http://baobab.wdjcdn.com/14564977406580.mp4",
                    "http://baobab.wdjcdn.com/1456316686552The.mp4",
                    "http://baobab.wdjcdn.com/1456480115661mtl.mp4",
                    "http://baobab.wdjcdn.com/1456665467509qingshu.mp4",
                    "http://baobab.wdjcdn.com/1455614108256t(2).mp4",
                    "http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4",
                    "http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",
                    "http://baobab.wdjcdn.com/1456734464766B(13).mp4",
                    "http://baobab.wdjcdn.com/1456653443902B.mp4",
                    "http://baobab.wdjcdn.com/1456231710844S(24).mp4"]
        let random = Int(arc4random_uniform(UInt32(urls.count)))
        
        self.player.changePlay(palyUrl: urls[random], title: "")
    }

    
    
    
    deinit {
        // 销毁播放器
        self.player.prepareToDealloc()
        print("prepareToDealloc")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.player.prepareToDealloc()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
