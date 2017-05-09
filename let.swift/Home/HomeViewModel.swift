//
//  HomeViewModel.swift
//  let.swift
//
//  Created by wenjin on 5/6/17.
//  Copyright © 2017 aaaron7. All rights reserved.
//

import Foundation

class HomeViewModel
{
    var todos : Signal<[TodoModelItem]> = Signal(value: [])
    var finishedTodos : Signal<[TodoModelItem]> = Signal(value: [])
    var showIndicator : Signal<Bool> = Signal(value: false)
    var timeValue : Signal<String>
    var todoModel : TodoModel = TodoModel()
    
    var todoCount : Int{
        get{
            return todos.peek().count
        }
    }
    
    var finishedCount : Int{
        get{
            return finishedTodos.peek().count
        }
    }
    
    init ()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM yyyy"
        let stringDate = dateFormatter.string(from: NSDate() as Date)
        timeValue = Signal(value : stringDate)
        updateTodo()
    }

    func updateTodo()
    {
        todoModel.getAllModelsAsync { (x) in
            self.todos.update(x.filter({ (item) -> Bool in
                item.status.peek() == .Normal
            }))
            
            self.finishedTodos.update(x.filter({ (item) -> Bool in
                item.status.peek() == .Finished
            }))
        }
    }
    
    func checkedTodo(index : Int, newStatus : TodoStatus)
    {
        var sourceArr : [TodoModelItem]
        if newStatus == .Normal{
            sourceArr = finishedTodos.peek()
        }else{
            sourceArr = todos.peek()
        }
        
        guard index < sourceArr.count else{
            return
        }
        
        let item = sourceArr[index]
        item.status.update(newStatus)
        todoModel.updateTodoStatusAsync(todo: item) { (req) in
            if req == .Success
            {
                self.updateTodo()
            }
        }
    }
    
    func addTodo(content : String, complete : @escaping (Bool) -> Void)
    {
        showIndicator.update(true)
        
        let item = TodoModelItem(timeStamp: Signal<Double>(value : 0), title: Signal<String>(value : content), status: Signal<TodoStatus>(value : .Normal), objectId: Signal(value : ""))
        
        todoModel.sendTodoAsync(todo: item, complete: { (status : ReqStatus) in
            self.showIndicator.update(false)
            complete(status == .Success)
            
            if (status == .Success)
            {
                self.updateTodo()
            }
        })
    }
}
