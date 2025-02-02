//
//  Task.swift
//  SwiftDataAmplifyApp.App
//
//  Created by ipeerless on 02/02/2025.
//

import Foundation
import SwiftData

@Model
class Task: Identifiable {
    var id: String
    var title: String
    var isCompleted: Bool

    init(id: String = UUID().uuidString, title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

