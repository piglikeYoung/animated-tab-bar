//  AnimationTabBarController.swift
//
// Copyright (c) 11/10/14 Ramotion Inc. (http://ramotion.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

extension RAMAnimatedTabBarItem {
    
    // 重写badgeValue，赋值时会跳到这
    override var badgeValue: String? {
        get {
            return badge?.text
        }
        set(newValue) {
            
            if newValue == nil {
                badge?.removeFromSuperview()
                badge = nil;
                return
            }
            
            if badge == nil {
                badge = RAMBadge.bage()
                if let contanerView = self.iconView!.icon.superview {
                    badge!.addBadgeOnView(contanerView)
                }
            }
            
            badge?.text = newValue
        }
    }
}


class RAMAnimatedTabBarItem: UITabBarItem {
    
    @IBOutlet weak var animation: RAMItemAnimation!
    @IBInspectable var textColor: UIColor = UIColor.blackColor()
    
    var badge: RAMBadge? // use badgeValue to show badge
    
    var iconView: (icon: UIImageView, textLabel: UILabel)?
    
    func playAnimation() {
        
        assert(animation != nil, "add animation in UITabBarItem")
        if animation != nil && iconView != nil {
            animation.playAnimation(iconView!.icon, textLabel: iconView!.textLabel)
        }
    }
    
    func deselectAnimation() {
        if animation != nil && iconView != nil {
            animation.deselectAnimation(iconView!.icon, textLabel: iconView!.textLabel, defaultTextColor: textColor)
        }
    }
    
    func selectedState() {
        if animation != nil && iconView != nil {
            animation.selectedState(iconView!.icon, textLabel: iconView!.textLabel)
        }
    }
}

extension  RAMAnimatedTabBarController {
    
    /**
     改变Item的颜色
     
     - parameter textSelectedColor: 文字颜色
     - parameter iconSelectedColor: Icon颜色
     */
    func changeSelectedColor(textSelectedColor:UIColor, iconSelectedColor:UIColor) {
        
        let items = tabBar.items as! [RAMAnimatedTabBarItem]
        for var index = 0; index < items.count; ++index {
            let item = items[index]
            
            item.animation.textSelectedColor = textSelectedColor
            item.animation.iconSelectedColor = iconSelectedColor
            
            if item == self.tabBar.selectedItem {
                item.selectedState()
            }
        }
    }
    
    /**
     隐藏TabBar
     
     - parameter isHidden: 是否隐藏
     */
    func animationTabBarHidden(isHidden:Bool) {
        let items = tabBar.items as! [RAMAnimatedTabBarItem]
        for item in items {
            if let iconView = item.iconView {
                iconView.icon.superview?.hidden = isHidden
            }
        }
        self.tabBar.hidden = isHidden;
    }
}


class RAMAnimatedTabBarController: UITabBarController {
    
    // MARK: life circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建5个对应的容器view
        let containers = createViewContainers()
        
        // 把原生的Item图片和文字转移到创建的容器View上
        createCustomIcons(containers)
    }
    
    // MARK: create methods
    
    func createCustomIcons(containers : NSDictionary) {
        
        if let _ = tabBar.items {
            let itemsCount = tabBar.items!.count as Int - 1
            var index = 0
            for item in self.tabBar.items as! [RAMAnimatedTabBarItem] {
                
                assert(item.image != nil, "add image icon in UITabBarItem")
                
                let container : UIView = containers["container\(itemsCount-index)"] as! UIView
                container.tag = index
                
                let icon = UIImageView(image: item.image)
                icon.translatesAutoresizingMaskIntoConstraints = false
                icon.tintColor = UIColor.clearColor()
                
                // text
                let textLabel = UILabel()
                textLabel.text = item.title
                textLabel.backgroundColor = UIColor.clearColor()
                textLabel.textColor = item.textColor
                textLabel.font = UIFont.systemFontOfSize(10)
                textLabel.textAlignment = NSTextAlignment.Center
                textLabel.translatesAutoresizingMaskIntoConstraints = false
                
                container.addSubview(icon)
                createConstraints(icon, container: container, size: item.image!.size, yOffset: -5)
                
                container.addSubview(textLabel)
                let textLabelWidth = tabBar.frame.size.width / CGFloat(tabBar.items!.count) - 5.0
                createConstraints(textLabel, container: container, size: CGSize(width: textLabelWidth , height: 10), yOffset: 16)
                
                item.iconView = (icon:icon, textLabel:textLabel)
                
                if 0 == index { // selected first elemet
                    item.selectedState()
                }
                
                item.image = nil
                item.title = ""
                index++
            }
        }
    }
    
    /**
     布局容器子控件
     
     - parameter view:      子控件
     - parameter container: 容器
     - parameter size:      大小
     - parameter yOffset:   y轴的值
     */
    func createConstraints(view:UIView, container:UIView, size:CGSize, yOffset:CGFloat) {
        
        let constX = NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: container,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0)
        container.addConstraint(constX)
        
        let constY = NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: container,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: yOffset)
        container.addConstraint(constY)
        
        let constW = NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: size.width)
        view.addConstraint(constW)
        
        let constH = NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: size.height)
        view.addConstraint(constH)
    }
    
    /**
     创建5个自定义容器
     
     - returns: 容器字典
     */
    func createViewContainers() -> NSDictionary {
        
        var containersDict = [String: AnyObject]()
        let itemsCount : Int = tabBar.items!.count as Int - 1
        
        for index in 0...itemsCount {
            // 创建容器view
            let viewContainer = createViewContainer()
            containersDict["container\(index)"] = viewContainer
        }
        
        //let keys = containersDict.keys
        
        var formatString = "H:|-(0)-[container0]"
        for index in 1...itemsCount {
            formatString += "-(0)-[container\(index)(==container0)]"
        }
        formatString += "-(0)-|"
        let  constranints = NSLayoutConstraint.constraintsWithVisualFormat(formatString,
            options:NSLayoutFormatOptions.DirectionRightToLeft,
            metrics: nil,
            views: (containersDict as [String : AnyObject]))
        view.addConstraints(constranints)
        
        return containersDict
    }
    
    /**
     创建装载TabBarItem的View
     
     - returns: 自定义View
     */
    func createViewContainer() -> UIView {
        // 创建View
        let viewContainer = UIView();
        viewContainer.backgroundColor = UIColor.clearColor() // for test
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewContainer)
        
        // 添加手势
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapHandler:")
        tapGesture.numberOfTouchesRequired = 1
        viewContainer.addGestureRecognizer(tapGesture)
        
        // 添加布局
        let constY = NSLayoutConstraint(item: viewContainer,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0)
        
        view.addConstraint(constY)
        
        let constH = NSLayoutConstraint(item: viewContainer,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: tabBar.frame.size.height)
        viewContainer.addConstraint(constH)
        
        return viewContainer
    }
    
    // MARK: actions
    
    /**
    轻触手势响应
    
    - parameter gesture: 手势
    */
    func tapHandler(gesture:UIGestureRecognizer) {
        
        let items = tabBar.items as! [RAMAnimatedTabBarItem]
        
        let currentIndex = gesture.view!.tag
        
        if let shouldSelect = delegate?.tabBarController?(self, shouldSelectViewController: self)
            where !shouldSelect {
            return
        }
        
        if selectedIndex != currentIndex {
            // 不是前一个选中的Item
            let animationItem : RAMAnimatedTabBarItem = items[currentIndex]
            // 开启动画
            animationItem.playAnimation()
            
            // 前一个Item关闭动画
            let deselectItem = items[selectedIndex]
            deselectItem.deselectAnimation()
            
            // 选中index赋值
            selectedIndex = gesture.view!.tag

            delegate?.tabBarController?(self, didSelectViewController: self)
        } else if selectedIndex == currentIndex {
            
            // 如果是导航控制器，跳转到导航控制器对应的根控制器
            if let navVC = self.viewControllers![selectedIndex] as? UINavigationController {
                navVC.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    func setSelectIndex(from from:Int,to:Int) {
        self.selectedIndex = to
        let items = self.tabBar.items as! [RAMAnimatedTabBarItem]
        items[from].deselectAnimation()
        items[to].playAnimation()
    }
}
