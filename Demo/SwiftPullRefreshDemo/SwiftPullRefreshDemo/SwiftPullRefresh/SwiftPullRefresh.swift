//
//  SwiftPullRefresh.swift
//  SwiftPullRefreshDemo
//
//  Created by jins on 14/10/29.
//  Copyright (c) 2014年 BlackWater. All rights reserved.
//

import UIKit

public class RefreshControl: UIControl {
    
    var label: UILabel!
    public var refreshClosure: (()->())!
    
    var superScrollView: UIScrollView {
        return self.superview as UIScrollView
    }
    
    // Event
    let dragEvent = Event(name: "drag", code: "drag")
    let thresholdEvent = Event(name: "threshold", code: "threshold")
    let releaseEvent = Event(name: "release", code: "release")
    let twoEvent = Event(name: "two", code: "two")
    let resetEvent = Event(name: "reset", code: "reset")
    
    // State
    let idle = StateType(name: "idle")
    let draging = StateType(name: "draging") //显示数值
    let ready = StateType(name: "ready")
    let refreshing = StateType(name: "refreshing")
    let end = StateType(name: "end")
    
    
    
    // Machine
    var machine: StateMachine
    
    // Controller
    var controller: Controller
    
    
    override init(frame: CGRect) {
        // Transition
        idle.addTransition(dragEvent, toState: draging)
        draging.addTransition(thresholdEvent, toState: ready)
        draging.addTransition(dragEvent, toState: draging)
        ready.addTransition(releaseEvent, toState: refreshing)
        ready.addTransition(dragEvent, toState: draging)
        refreshing.addTransition(twoEvent, toState: end)
        end.addTransition(dragEvent, toState: draging)
        
        machine = StateMachine(initState: idle)
        machine.addResetEvents(resetEvent)
        
        controller = Controller(currentState: idle, machine: machine)
        
        
        super.init(frame: frame)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginRefresh() {
        
    }
    func endRefresh() {
        controller.handle("two")
    }
    
    func setupUI() {
        let label = UILabel(frame: CGRectMake(0, 0, 200, 20))
        label.textAlignment = NSTextAlignment.Center
        label.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin
        label.center = CGPointMake(CGRectGetMidX(self.bounds), -CGRectGetHeight(label.frame) / 2 - 5)
        self.addSubview(label)
        self.label = label
    }
    
    func setupAction() {
        // add action
        draging.entry = {
            println("drag")
            self.label.text = "正在拖动"
        }
        ready.entry = {
            println("ready")
            self.label.text = "准备刷新"
        }
        refreshing.entry = {
            println("refreshing")
            self.label.text = "正在刷新"
            
            // update inset
            UIView.animateWithDuration(0.5) {
                var insets = self.superScrollView.contentInset
                insets.top += self.refreshControlThreshold()
                self.superScrollView.contentInset = insets
            }
            // update offset
//            self.superScrollView.setContentOffset(CGPointMake(0, -insets.top), animated: true)
            self.refreshClosure()
        }
        end.entry = {
            println("end")
            self.label.text = "刷新成功"
            
            // update inset
            UIView.animateWithDuration(0.5) {
                var insets = self.superScrollView.contentInset
                insets.top -= self.refreshControlThreshold()
                self.superScrollView.contentInset = insets
            }

            // update offset
//            var contentOffset = self.superScrollView.contentOffset
//            contentOffset.y = 0//-insets.top
//            UIView.animateWithDuration(0.25, animations: {
//                self.superScrollView.contentOffset = contentOffset
//            })
//            self.superScrollView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.superview?.sendSubviewToBack(self) //?
        controller.handle("reset")
        // UI setup
        setupUI()
        setupAction()
        self.superview?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New, context: nil)
    }
    
    override public func removeFromSuperview() {
        super.removeFromSuperview()
        self.superview?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override public func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset" {
            let point = change[NSKeyValueChangeNewKey]?.CGPointValue()
            if let pointY = point?.y {
                println(pointY)
                if pointY < -100.0 {
                    controller.handle("threshold")
                    if !superScrollView.tracking {
                        controller.handle("release")
                    }
                } else {
                    controller.handle("drag")
                }
            }
        }
    }
    
    func refreshControlThreshold() -> CGFloat {
        return 100.0
    }
}