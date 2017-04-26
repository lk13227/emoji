//
//  LKKeyboardEmoticonViewController.swift
//  表请键盘
//
//  Created by LiuKai on 2017/4/21.
//  Copyright © 2017年 天高云展. All rights reserved.
//

import UIKit

class LKKeyboardEmoticonViewController: UIViewController {

    /// 保存所有组数据
    var packages: [LKKeyboardPackage] = LKKeyboardPackage.loadEmotionPackages()
    
    /// 点击表情的回调闭包
    var emoticonCallback: (_ emoticon: LKKeyboardEmoticon) -> ()
    
    init(callBack: @escaping(_ emoticon: LKKeyboardEmoticon)->()) {
        
        self.emoticonCallback = callBack
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.green
        
        // 添加子控件
        view.addSubview(collectionView)
        view.addSubview(toolbar)
        
        // 关闭系统自行约束
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        // 布局子控件
        let dict: [String: Any] = ["collectionView": collectionView, "toolbar": toolbar]
        var cons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolbar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-[toolbar(49)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        view.addConstraints(cons)
    }
    
    // MARK: - 内部控制方法
    @objc private func itemClick(item: UIBarButtonItem)
    {
        // 创建 indexPath
        let indexPaht = IndexPath(item: 0, section: item.tag)
        // 滚动到对应的 indexPath
        collectionView.scrollToItem(at: indexPaht, at: UICollectionViewScrollPosition.left, animated: true)
    }

    // MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {
        let clv = UICollectionView(frame: CGRect.zero, collectionViewLayout: LKKeyboardEmoticonLayout())
        clv.backgroundColor = UIColor.blue
        clv.dataSource = self
        clv.delegate = self
        clv.register(LKKeyboardEmoticonCell.self, forCellWithReuseIdentifier: "keyboardCell")
        return clv
    }()
    
    private lazy var toolbar: UIToolbar = {
        let tb = UIToolbar()
        tb.tintColor = UIColor.lightGray
        var index = 0
        var items = [UIBarButtonItem]()
        for title in ["最近", "默认", "Emoji", "浪小花"]
        {
            // 创建 item
            let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(LKKeyboardEmoticonViewController.itemClick(item:)))
            item.tag = index
            index += 1
            items.append(item)
            // 添加间隙弹簧
            let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            items.append(flexibleItem)
        }
        // 删除多余弹簧
        items.removeLast()
        // 将 item 添加到 toolbar
        tb.items = items
        return tb
    }()

}

extension LKKeyboardEmoticonViewController: UICollectionViewDataSource
{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packages[section].emoticons?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "keyboardCell", for: indexPath) as! LKKeyboardEmoticonCell
        
        cell.backgroundColor = (indexPath.item % 2 == 0) ? UIColor.purple : UIColor.red
        cell.emoticon = packages[indexPath.section].emoticons![indexPath.item]
        
        return cell
    }
    
}

extension LKKeyboardEmoticonViewController: UICollectionViewDelegate
{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 取出点击的表情
        let package = packages[indexPath.section]
        let emoticon = package.emoticons![indexPath.item]
        
        // 每使用一次就+1
        emoticon.count += 1
        // 判断是否是删除按钮
        if !emoticon.isRemoveButton
        {
            // 将当前点击的表情添加到最近组中
            packages[0].addFavoriteEmoticon(emoticon: emoticon)
        }
        
        // 将表情传递出去
        emoticonCallback(emoticon)
        
    }
    
}

class LKKeyboardEmoticonLayout: UICollectionViewFlowLayout
{
    override func prepare() {
        super.prepare()
        
        // 计算 cell 宽度
        let width = UIScreen.main.bounds.width / 7
        let height = collectionView!.bounds.height / 3
        itemSize = CGSize(width: width, height: height)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.horizontal
        // 设置 collectionView
        collectionView?.bounces = false
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        // 设置间隙
//        let offsetY = (collectionView!.frame.height - 3 * width) * 0.49
//        collectionView?.contentInset = UIEdgeInsets(top: offsetY, left: 0, bottom: offsetY, right: 0)
    }
}
