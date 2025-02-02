//
//  TaskService.swift
//  SwiftUI+SwiftData+DATABASES.App
//
//  Created by ipeerless on 02/02/2025.
//

import Amplify
import Foundation

@Observable
 final class TaskService {
    
    func fetchTasksFromAmplify() async throws -> [Task] {
            let amplifyTasks = try await Amplify.DataStore.query(Task.self)
            return amplifyTasks.map { amplifyTask in
                Task(
                    id: amplifyTask.id,
                    title: amplifyTask.title,
                    isCompleted: amplifyTask.isCompleted
                )
            }
        }
    func saveTaskToAmplify(_ task: Task) async throws {
        let amplifyTask = Task(id: task.id,title: task.title, isCompleted: task.isCompleted)
    }
      
}
