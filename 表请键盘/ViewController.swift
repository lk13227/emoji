//
//  ViewController.swift
//  表请键盘
//
//  Created by LiuKai on 2017/4/21.
//  Copyright © 2017年 天高云展. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cutomTextView: LKKeyboardTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 将键盘控制 添加为当前控制器的子控件
        addChildViewController(keyboardEmoticonVC)
        // 将键盘控制的 view 设置为自定义键盘
        cutomTextView.inputView = keyboardEmoticonVC.view
    }

    private lazy var keyboardEmoticonVC: LKKeyboardEmoticonViewController = LKKeyboardEmoticonViewController { [unowned self] (emoticon) in
        
        self.cutomTextView.insertEmoticon(emoticon: emoticon)
        
    }
    
    
    @IBAction func btnClick(_ sender: Any)
    {
        
        print(self.cutomTextView.emoticonStr())
        
    }

}

