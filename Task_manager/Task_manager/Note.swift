//
//  Note.swift
//  Task_manager
//
//  Created by Ondřej Měchura on 01.06.18.
//  Copyright © 2018 Ondřej Měchura. All rights reserved.
//

import UIKit

class Note:NSObject{
    
    
    var id:String!
    var title:String!
    var notes:String!
    var day:String!
    var month:String!
    var year:String!
    var color:String!
    var locked:Bool?
    var method:String!
    var password:String!
    
    
    override init() {
        
    }
    
    init(id:String,title:String,notes:String,day:String, month:String, year:String, color:String, locked:Bool, method:String, password:String){
        
        self.id = id
        self.title = title
        self.notes = notes
        self.day = day
        self.month = month
        self.year = year
        self.color = color
        self.locked = locked
        self.method = method
        self.password = password
    }
    
    
}





    
    
    
    
    
    
    
    
    
    
    
    


