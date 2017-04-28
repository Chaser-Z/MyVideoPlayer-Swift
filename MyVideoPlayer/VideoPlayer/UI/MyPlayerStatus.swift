//
//  MyPlayerStatus.swift
//  MyVideoPlayer
//
//  Created by 张海南 on 2017/4/25.
//  Copyright © 2017年 Beijing Han-sky Education Technology Co. All rights reserved.
//

import UIKit

// 播放状态
enum MyPlayerStatus {
    
    case playing         // 播放中
    case pause           // 暂停
    case end             // 结束
    case readyToPlay     // 准备播放
    case failed          // 播放失败
    case unknown         // 不明错误
    case none            // 开始默认
    
}
// 缓冲状态
enum MyPlayerBufferStatus {
    
    case buffering       // 缓冲状态
    case bufferEnd       // 缓冲结束
    case bufferFinished  // 缓冲完成
    case error           // 缓冲错误
    case none            // 没有状态
    
}

// 手势控制
enum ControlType {
    case noneControl       // 无
    case progressControl   // 进度条
    case voiceControl      // 声音
    case lightControl      // 亮度
    
}
// slider 滑动状态
enum MyPlayerSeekStatus {
    case seeking           // 滑动状态
    case end               // 滑动结束
    case none              // 没有
}
