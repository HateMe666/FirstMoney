//
//  SpendingModel.swift
//  FirstMoney(YouTube)
//
//  Created by Nikita Kuzmich on 30.08.21.
//

import RealmSwift
import UIKit

class Spending: Object {
    @objc dynamic var category = ""
    @objc dynamic var cost = 1
    @objc dynamic var date = Date()
    
}
class Limit: Object {
    @objc dynamic var limitSome = ""
    @objc dynamic var limitDate = NSDate()
    @objc dynamic var limitLastDate = NSDate()
    
}
