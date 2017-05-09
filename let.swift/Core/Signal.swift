//
//  Signal.swift
//  let.swift
//
//  Created by wenjin on 5/1/17.
//  Copyright © 2017 aaaron7. All rights reserved.
//

import Foundation
import UIKit

public class Signal<a> : NSObject
{
    public typealias SignalToken = Int
    fileprivate typealias Subscriber = (a) -> Void
    fileprivate var subscribers = [SignalToken:Subscriber]()
    public private(set) var value : a
    
    fileprivate var bindedObject : [(NSObject, String)] = []
    
    let queue = DispatchQueue(label: "com.swift.let.token")

    init(value : a)
    {
        self.value = value
    }
    
    public func subscribeNext(hasInitialValue:Bool = false, subscriber : @escaping (a) -> Void) -> SignalToken
    {
        var token : SignalToken = 0
        queue.sync{
            token = (subscribers.keys.max() ?? 0) + 1
            subscribers[token] = subscriber
            
            if hasInitialValue{
                subscriber(value)
            }
        }
        
        return token
    }
    
    public func unscrible(token : SignalToken)
    {
        queue.sync{
            subscribers[token] = nil
        }
    }
    
    public func bind(signal : Signal<a>) -> SignalToken
    {
        let token = self.subscribeNext { (newValue : a) in
            signal.update(newValue)
        }
        
        return token
    }
    
    public func unbind(token : SignalToken)
    {
        unscrible(token: token)
    }
    
    public func update(_ value : a)
    {
        queue.sync{
            self.value = value
            for sub in subscribers.values {
                sub(value)
            }
        }
    }
    
    public func peek() -> a
    {
        return value
    }
    
    deinit
    {
        for object in bindedObject{
            object.0.removeObserver(self, forKeyPath: object.1)
        }
    }
    
}

extension Signal
{
    public func map<b>(f : @escaping (a) -> b) -> Signal<b>
    {
        let mappedValue = f(self.value)
        return Signal<b>(value: mappedValue)
    }
    
    public func filter(f : @escaping (a) -> Bool) -> Signal<a>?
    {
        if f(self.value){
            return self
        }else{
            return nil
        }
    }
}


extension Signal
{
    public func bind(to control:NSObject, keyPath:String)
    {
        _ = self.subscribeNext(hasInitialValue: true, subscriber: { (v : a) in
            control.setValue(v, forKey: keyPath)
        })
    }
    

}
