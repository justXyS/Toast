//
//  UIView+Toast.swift
//  Demo
//
//  Created by xiaoyuan on 2017/6/16.
//  Copyright © 2017年 xiaoyuan. All rights reserved.
//

import UIKit

public class ToastStyle {
    
    public static let shared = ToastStyle()
    
    public var backgroundColor = UIColor.black.withAlphaComponent(0.6)
    
    public var font = UIFont.systemFont(ofSize: 12)
    
    public var textColor = UIColor.white
    
}

public class Toast: NSObject {
    public typealias Length = TimeInterval
    public static let LENGTH_SHORT: Length = 1
    public static let LENGTH_LONG: Length = 2
    
    private let toastContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.alpha = 0
        return view
    }()
    
    private let tipsLabel: UILabel = {
        let toastLabel = UILabel()
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = UIColor.clear
        return toastLabel
    }()
    
    private var queue:[(String,Length,Posisiton)] = []
    
    
    public enum Posisiton {
        case bottom(CGFloat)
        case center(CGFloat)
    }
    
    private weak var view: UIView?
    
    init(view: UIView) {
        self.view = view
    }
    
    ///show toast
    /// - Parameters:
    ///     - text: 要显示的文本
    ///     - duration: toast持续时间, 默认是 LENGTH_LONG
    ///     - position: toast显示位置, CGFloat 用来 调整 toast y 偏移量, 默认是 .bottom(0)
    ///     - style: toast风格设置 默认是白字黑底12号字体
    open func show(text: String, duration: Length = LENGTH_LONG, position: Posisiton = .bottom(0), style: ToastStyle = ToastStyle.shared) {
        
        guard let view = view else {
            return
        }
        
        if toastContainer.superview != nil {
            queue.append((text, duration, position))
            return
        }
        
        let toastLabel = tipsLabel
        toastLabel.font = style.font
        toastLabel.textColor = style.textColor
        toastLabel.text = text
        toastLabel.sizeToFit()
        toastLabel.frame.origin = CGPoint(x: 5, y: 3)
        
        var f = toastLabel.frame
        f.size.width += 10
        f.size.height += 6
        
        switch position {
            case .bottom(let y):
                f.origin.x = (view.frame.width - f.size.width) / 2
                f.origin.y = view.frame.height - f.size.height - 20.0 + y
                toastContainer.frame = f
            case .center(let y):
                toastContainer.frame = f
                toastContainer.center = CGPoint(x: view.center.x, y: view.center.y + y)
        }
        
        toastContainer.backgroundColor = style.backgroundColor
        toastContainer.addSubview(toastLabel)
        view.addSubview(toastContainer)
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let sself = self else { return }
            sself.toastContainer.alpha = 1
        }
        
        perform(#selector(hidden), with: self, afterDelay: duration)
    }
    
    @objc private func hidden() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: { [weak self] in
            guard let sself = self else { return }
            sself.toastContainer.alpha = 0
        }) { [weak self] _ in
            guard let sself = self else { return }
            sself.toastContainer.removeFromSuperview()
            if !sself.queue.isEmpty {
                let first = sself.queue.removeFirst()
                sself.show(text: first.0, duration: first.1, position: first.2)
            }
        }
    }
    
    /// 调用此方法清除处于队列中的Toast，如果队列里面有待展示的Toast，务必在view销毁的时候调用此方法
    public func clear() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        queue.removeAll()
    }
    
}

var toastKey = ""

extension UIView {
    /// Toast生成器
    public var toast: Toast {
        get {
            var toast = objc_getAssociatedObject(self, &toastKey) as? Toast
            if toast == nil {
                toast = Toast(view: self)
                objc_setAssociatedObject(self,  &toastKey, toast, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return toast!
        }
    }
}

