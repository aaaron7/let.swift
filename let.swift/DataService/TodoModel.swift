//
//  TodoModel.swift
//  let.swift
//
//  Created by wenjin on 5/6/17.
//  Copyright © 2017 aaaron7. All rights reserved.
//

import Foundation
import Networking

enum TodoStatus
{
    case Normal
    case Finished
}

enum ReqStatus
{
    case Success
    case Failed
}

public struct TodoModelItem
{
    var timeStamp : Signal<Double>
    var title : Signal<String>
    var status : Signal<TodoStatus>
    var objectId : Signal<String>
}

class TodoModel
{
    let baseUrl = "http://letstodo.leanapp.cn"
    let statusMap : [String : TodoStatus] = ["todo":.Normal, "finished":.Finished]
    let invStatusMap : [TodoStatus : String] = [.Normal : "todo", .Finished : "finished"]
    
    func getAllModelsAsync(complete : @escaping ([TodoModelItem]) -> Void)
    {
        Networking(baseURL: baseUrl).get("/todos/list", completion: { (jr : JSONResult) in
            switch jr {
            case .success(let response):
                let json = response.arrayBody
                print(json)
                let arr = json.map({ (x : [String : Any]) -> TodoModelItem in
                    return TodoModelItem(timeStamp: Signal<Double>(value: 0),
                                         title: Signal(value: x["content"] as! String),
                                         status: Signal<TodoStatus>(value: self.statusMap[x["status"] as! String]!),
                                         objectId: Signal<String>(value: x["objectId"] as! String))
                })
                complete(arr)
                
            case .failure(_):
                break
            }
        })
    }
    
    func sendTodoAsync(todo : TodoModelItem, complete : @escaping (ReqStatus) -> Void)
    {
        Networking(baseURL : baseUrl).post("/todos/list", parameterType: .formURLEncoded, parameters: ["content":todo.title.peek()]) { (jr) in
            switch jr{
            case .success(let response):
                let json = response.arrayBody
                print(json)
                complete(.Success)
            case .failure(_):
                complete(.Failed)
                break
            }
        }
    }
    
    func updateTodoStatusAsync(todo : TodoModelItem, complete : @escaping (ReqStatus) -> Void)
    {
        Networking(baseURL : baseUrl).post("/todos/list/update", parameterType: .formURLEncoded, parameters: ["objectId": todo.objectId.peek(), "status" : invStatusMap[todo.status.peek()]!]) { (jr) in
            switch jr{
            case .success(let response):
                let json = response.arrayBody
                print(json)
                complete(.Success)
            case .failure(let err):
                print(err)
                complete(.Failed)
                break
            }
        }
    }
}
