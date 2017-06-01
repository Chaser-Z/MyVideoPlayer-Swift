//
//  MyPlayerResource.swift
//  MyVideoPlayer
//
//  Created by 张海南 on 2017/6/1.
//  Copyright © 2017年 Beijing Han-sky Education Technology Co. All rights reserved.
//

import UIKit

func GetPlayResource() -> MySubtitles?{
    
    let url = Bundle.main.url(forResource: "SubtitleDemo", withExtension: "srt")
    
    var subtitles: MySubtitles? = nil
    
    if url != nil {
        
        subtitles = MySubtitles(url: url!)
    }
    
    return subtitles
    
}
