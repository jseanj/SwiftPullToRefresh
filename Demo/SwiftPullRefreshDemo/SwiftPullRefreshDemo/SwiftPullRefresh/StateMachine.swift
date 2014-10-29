//
//  StateMachine.swift
//  SwiftPullRefreshDemo
//
//  Created by jins on 14/10/29.
//  Copyright (c) 2014年 BlackWater. All rights reserved.
//

import Foundation

protocol EventType {
    var name: String {get set}
    var code: String {get set}
}

struct Event {
    var name: String
    var code: String
}
//为什么struct不可以
class StateType {
    var name: String!
    var entry: (()->())?
    var exit: (()->())?
    var transitions: [String: Transition] = [:]
    
    init(name: String, entry: (()->())? = nil, exit: (()->())? = nil) {
        self.name = name
        self.entry = entry
        self.exit = exit
    }
    
    func hasTransition(eventCode: String) -> Bool {
        return transitions[eventCode] != nil ? true : false
    }
    
    func addTransition(event: Event, toState: StateType) {
        transitions[ event.code ] = Transition(from: self, to: toState, trigger: event)
    }
    
    func getAllToStates() -> [StateType] {
        var result = [StateType]()
        for transition in transitions.values {
            result.append(transition.to)
        }
        return result
    }
    
    // 根据事件获得下一个状态
    func getToState(eventCode: String) -> StateType? {
        if transitions[eventCode] != nil {
            let transition = transitions[eventCode] as Transition?
            return transition!.to
        }
        return nil
    }
    func executeEntry() {
        if entry != nil {
            entry!()
        }
    }
    func executeExit() {
        if exit != nil {
            exit!()
        }
    }
}

struct Transition {
    var from: StateType
    var to: StateType
    var trigger: Event
}

class StateMachine {
    var initState: StateType
    var resetEvents = [Event]()
    
    init(initState: StateType) {
        self.initState = initState
    }
    
    func addResetEvents(events: Event...) {
        for event in events {
            resetEvents.append(event)
        }
    }
    
    func addResetEventByAddingTransitions(event: Event) {
        
    }
    
    func isResetEvent(eventCode: String) -> Bool {
        for resetEvent in resetEvents {
            if resetEvent.code == eventCode {
                return true
            }
        }
        return false
    }
    
    //    func getAllStatesFromState(fromeState: StateType) -> [StateType] {
    //        var result = [StateType]()
    //        for state in fromeState.getAllToStates() {
    //            result += getAllStatesFromState(state)
    //        }
    //        return result
    //    }
}

class Controller {
    var currentState: StateType
    var machine: StateMachine
    init(currentState: StateType, machine: StateMachine) {
        self.currentState = currentState
        self.machine = machine
    }
    func handle(eventCode: String) {
        if currentState.hasTransition(eventCode) {
            // 如果当前状态可以转移，则转移到对应的状态
            transitionToState(currentState.getToState(eventCode)!)
        } else if (machine.isResetEvent(eventCode)) {
            // 如果是重置事件，则转移到初始状态
            transitionToState(machine.initState)
        }
    }
    
    // 转移状态
    func transitionToState(toState: StateType) {
        currentState.executeExit()
        currentState = toState
        currentState.executeEntry()
    }
}
