//
//  LKKeyboardPackage.swift
//  表请键盘
//
//  Created by LiuKai on 2017/4/24.
//  Copyright © 2017年 天高云展. All rights reserved.
//

import UIKit

class LKKeyboardPackage: NSObject {

    /// 当前组的名称
    var group_name_cn: String?
    /// 当前组对应的文件夹名称
    var id: String?
    /// 当前组所有的表情
    var emoticons: [LKKeyboardEmoticon]?
    
    init(id: String)
    {
        self.id = id
    }
    
    /// 加载所有组数据
    class func loadEmotionPackages() -> [LKKeyboardPackage]
    {
        var models = [LKKeyboardPackage]()
        
        // 手动添加最近组
        let package = LKKeyboardPackage(id: "")
        package.appendEmptyEmoticons()
        models.append(package)
        
        // 获取 emoticons 文件路径
        let path = Bundle.main.path(forResource: "emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        // 加载 emoticons.plist
        let dict = NSDictionary(contentsOfFile: path)!
        let array = dict["packages"] as! [[String: AnyObject]]
        // 取出所有组表情
        for packageDict in array
        {
            // 创建当前组模型
            let package = LKKeyboardPackage(id: packageDict["id"] as! String)
            // 加载当前组所有的表情数据
            package.loadEmoticons()
            // 补全一组数据 保证当前组能被21整除
            package.appendEmptyEmoticons()
            // 将当前组模型添加到数组中
            models.append(package)
        }
        
        return models
    }
    
    /// 加载当前组所有的表情
    private func loadEmoticons()
    {
        // 拼接当前组 info.plist 路径
        let path = Bundle.main.path(forResource: self.id, ofType: nil, inDirectory: "Emoticons.bundle")!
        let filePath = (path as NSString).strings(byAppendingPaths: ["info.plist"])
        // 根据路径加载 info.plist 文件
        let dict = NSDictionary(contentsOfFile: filePath.first!)!
        // 从加载进来的字典中取出当前组数据
        group_name_cn = dict["group_name_cn"] as? String
        let array = dict["emoticons"] as! [[String: AnyObject]]
        // 遍历数组 取出每一个表情
        var models = [LKKeyboardEmoticon]()
        var index = 0
        for emoticonDic in array
        {
            if index == 20
            {
                let emoticon = LKKeyboardEmoticon(isRemoveButton: true)
                models.append(emoticon)
                index = 0
                continue
            }
            let emoticon = LKKeyboardEmoticon(dict: emoticonDic, id: self.id!)
            models.append(emoticon)
            index += 1
        }
        emoticons = models
        
    }
    
    /// 补全一组表情
    private func appendEmptyEmoticons()
    {
        // 判断是否是最近组
        if emoticons == nil
        {
            emoticons = [LKKeyboardEmoticon]()
        }
        
        // 取出不能被21整除剩余的个数
        let number = emoticons!.count % 21
        // 补全
        for _ in number..<20
        {
            let emoticon = LKKeyboardEmoticon(isRemoveButton: false)
            emoticons?.append(emoticon)
        }
        // 补全删除按钮
        let emoticon = LKKeyboardEmoticon(isRemoveButton: true)
        emoticons?.append(emoticon)
        
    }
    
    /// 添加最近表情
    func addFavoriteEmoticon(emoticon: LKKeyboardEmoticon)
    {
        emoticons?.removeLast()
        
        // 判断当前表情是否添加过
        if !emoticons!.contains(emoticon)
        {
            // 添加当前点击的表情
            emoticons?.removeLast()
            emoticons?.append(emoticon)
        }
        
        // 对表情进行排序
        emoticons = emoticons?.sorted(by: { (e1, e2) -> Bool in
            return e1.count > e2.count
        })
        
        // 添加删除按钮
        emoticons?.append(LKKeyboardEmoticon(isRemoveButton: true))
        
    }
    
}

class LKKeyboardEmoticon: NSObject {
    
    /// 当前组对应的文件夹名称
    var id: String?
    /// 当前表情对应的字符串
    var chs: String?
    /// 当前表情对应的图片
    var png: String?
    {
        didSet{
            let path = Bundle.main.path(forResource: self.id, ofType: nil, inDirectory: "Emoticons.bundle")!
            pngPath = ((path as NSString).strings(byAppendingPaths: [png ?? ""])).first
        }
    }
    /// 当前表情图片的绝对路径
    var pngPath: String?
    /// Emoji表情对应的字符串
    var code: String?
    {
        didSet{
            // 创建一个扫描器
            let scanner = Scanner(string: code ?? "")
            // 从字符串中扫描对应的十六进制数
            var result: UInt32 = 0
            scanner.scanHexInt32(&result)
            // 根据扫描出的十六进制创建一个字符串
            emoticonStr = "\(Character(UnicodeScalar(result)!))"
        }
    }
    
    // 转换之后的 emoji 表情字符串
    var emoticonStr: String?
    
    /// 记录当前表情是否是删除按钮
    var isRemoveButton: Bool = false
    
    /// 记录当前表情的使用次数
    var count: Int = 0
    
    init(isRemoveButton: Bool) {
        self.isRemoveButton = isRemoveButton
    }
    
    init(dict: [String: AnyObject], id: String)
    {
        self.id = id
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
}
