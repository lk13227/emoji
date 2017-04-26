//
//  LKKeyboardTextView.swift
//  表请键盘
//
//  Created by LiuKai on 2017/4/26.
//  Copyright © 2017年 天高云展. All rights reserved.
//

import UIKit

class LKKeyboardTextView: UITextView {

    func insertEmoticon(emoticon: LKKeyboardEmoticon)
    {
        
        // emoji 表情的图文混排
        if let tempEmojiStr = emoticon.emoticonStr
        {
            // 取出光标所在位置
            let range = self.selectedTextRange!
            self.replace(range, withText: tempEmojiStr)
            
            return
        }
        
        // 新浪的图片的图文混排
        if let tempPngPath = emoticon.pngPath
        {
            // 创建属性字符串
            let attrmStr = NSMutableAttributedString(attributedString: self.attributedText)
            // 创建图片的属性字符串
            let attachment = LKKeyboardAttachment()
            attachment.emoticonChs = emoticon.chs
            let fontHeight = self.font!.lineHeight
            attachment.bounds = CGRect(x: 0, y: -5, width: fontHeight, height: fontHeight)
            attachment.image = UIImage(contentsOfFile: tempPngPath)
            let imageAttrStr = NSAttributedString(attachment: attachment)
            // 获取光标所在的位置
            let range = self.selectedRange
            // 将光标所在位置的字符串进行替换
            attrmStr.replaceCharacters(in: range, with: imageAttrStr)
            self.attributedText = attrmStr
            // 重新定位光标
            self.selectedRange = NSRange(location: range.location + 1, length: 0)
            // 重新设置字体大小
            self.font = UIFont.systemFont(ofSize: 18)
            
            
            return
        }
        
        // 删除最近一个文字或者表情
        if emoticon.isRemoveButton
        {
            self.deleteBackward()
        }
        
    }
    
    func emoticonStr() -> String
    {
        // 获取整个字符串的光标
        let range = NSRange(location: 0, length: self.attributedText.length)
        
        // 创建容器字符串
        var strM = String()
        
        // 遍历属性字符串
        self.attributedText.enumerateAttributes(in: range, options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (dict, range, _) in
            
            if let tempAttachment = dict["NSAttachment"] as? LKKeyboardAttachment
            {
                // 取出特殊字符串
                strM += tempAttachment.emoticonChs!
            } else {
                // 普通字符串
                strM += (self.text as NSString).substring(with: range)
            }
            
        }
        
        return strM
    }

}
