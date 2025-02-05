//
//  TaskModel.swift
//  SwiftUI+SwiftData+DATABASES.App
//
//  Created by ipeerless on 04/02/2025.
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
   

}
