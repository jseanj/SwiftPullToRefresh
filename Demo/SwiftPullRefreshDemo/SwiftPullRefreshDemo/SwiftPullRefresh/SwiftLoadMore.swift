//
//  SwiftLoadMore.swift
//  SwiftPullRefreshDemo
//
//  Created by jins on 14/12/5.
//  Copyright (c) 2014年 BlackWater. All rights reserved.
//

import UIKit

public class LoadMoreControl: UIControl {
    var label: UILabel!
    public var loadingClosure: (()->())?
    
    var superScrollView: UIScrollView {
        return self.superview as UIScrollView
    }
    
    // Event
    let updragEvent = Event(name: "updrag", code: "updrag")
    let touchEvent = Event(name: "touch", code: "touch")
    let twoEvent = Event(name: "two", code: "two")
    let twonodataEvent = Event(name: "twonodata", code: "twonodata")
    let secondEvent = Event(name: "second", code: "second")
    let resetEvent = Event(name: "reset", code: "reset")
    
    // State
    let ready = StateType(name: "ready")
    let loading = StateType(name: "loading")
    let success = StateType(name: "success")
    let nomore = StateType(name: "nomore")
    
    // Machine
    var machine: StateMachine
    
    // Controller
    var controller: Controller
    
    override init(frame: CGRect) {
        ready.addTransition(updragEvent, toState: loading)
        ready.addTransition(touchEvent, toState: loading)
        loading.addTransition(twoEvent, toState: success)
        loading.addTransition(twonodataEvent, toState: nomore)
        success.addTransition(secondEvent, toState: ready)
        
        machine = StateMachine(initState: ready)
        machine.addResetEvents(resetEvent)
        
        controller = Controller(currentState: ready, machine: machine)
        
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func successLoadMore() {
        controller.handle("two")
    }
    
    public func noLoadMore() {
        controller.handle("twonodata")
    }
    
    func setupUI() {
        let label = UILabel(frame: CGRectMake(0, 0, 200, 20))
        label.text = "加载更多"
        label.textAlignment = NSTextAlignment.Center
        label.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin
        label.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        self.addSubview(label)
        println(label)
        self.label = label
    }
    
    func setupAction() {
        // add action
        ready.entry = {
            println("ready")
            self.label.text = "加载更多"
        }
        loading.entry = {
            println("loading")
            self.label.text = "正在加载"

            if self.loadingClosure != nil {
                self.loadingClosure!()
            }
        }
        success.entry = {
            println("success")
            self.label.text = "加载成功"
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                self.controller.handle("second")
            })
        }
        
        nomore.entry = {
            println("no more")
            self.label.text = "没有更多"
        }
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.superview?.sendSubviewToBack(self) //?
        controller.handle("reset")
        // UI setup
        setupUI()
        setupAction()
        self.addTarget(self, action: Selector("touched"), forControlEvents: UIControlEvents.TouchUpInside)
        self.superview?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New, context: nil)
    }
    override public func removeFromSuperview() {
        super.removeFromSuperview()
        self.superview?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    func touched() {
        controller.handle("touch")
    }
    
    override public func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset" {
            let point = change[NSKeyValueChangeNewKey]?.CGPointValue()
            if let pointY = point?.y {
                let hight = UIScreen.mainScreen().bounds.height
                let contentHight = superScrollView.contentSize.height
                if pointY > (contentHight - hight) {
                    controller.handle("updrag")
                }
            }
        }
    }
}
