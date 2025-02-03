//
//  Task.swift
//  SwiftUI+SwiftData+DATABASES.App
//
//  Created by ipeerless on 02/02/2025.
//
//
import Foundation
import SwiftData

@Model
class TaskModel {
    @Attribute(.unique) var id: String
    var title: String
    var isCompleted: Bool
    
    init(id: String, title: String, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
    
    // Default initializer required by SwiftData
    init() {
        self.id = UUID().uuidString
        self.title = ""
        self.isCompleted = false
    }
}

//import SwiftData
//
//@Model
//class Task {
//    var id: String
//    var title: String
//    var isCompleted: Bool
//    
//    init(id: String, title: String, isCompleted: Bool) {
//        self.id = id
//        self.title = title
//        self.isCompleted = isCompleted
//    }
//}
