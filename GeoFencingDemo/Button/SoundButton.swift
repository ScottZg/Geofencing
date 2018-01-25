//
//  SoundButton.swift
//  GeoFencingDemo
//
//  Created by zhanggui on 2018/1/25.
//  Copyright © 2018年 zhanggui. All rights reserved.
//

import UIKit
import AVFoundation
class SoundButton: UIButton {

    var sounfFileObj: SystemSoundID = 0
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.playSound(soundName: "buttonTap", type: "caf")
    }
    func playSound(soundName name: String,type: String) {
        let soundPath = Bundle.main.path(forResource: name, ofType: type)
        let url = URL.init(fileURLWithPath: soundPath!)
        AudioServicesCreateSystemSoundID(url as CFURL, &sounfFileObj)
//        AudioServicesPlayAlertSound(sounfFileObj)  //有震动效果
        AudioServicesPlaySystemSound(sounfFileObj)   //仅音效
        
    }

}
