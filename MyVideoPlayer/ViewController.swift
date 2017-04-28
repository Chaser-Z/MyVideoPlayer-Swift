//
//  ViewController.swift
//  MyVideoPlayer
//
//  Created by 张海南 on 2017/4/25.
//  Copyright © 2017年 Beijing Han-sky Education Technology Co. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    @IBAction func nextAction(_ sender: Any) {
        
        let playVC = PlayViewController()
        self.navigationController?.pushViewController(playVC, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIColor {
    
    
    class func colorWith(redColor red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor {
        let color = UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
        return color
    }
    
    
    
    
}
