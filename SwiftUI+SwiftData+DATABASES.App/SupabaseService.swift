//
//  SupabaseService.swift
//  SwiftUI+SwiftData+DATABASES.App
//
//  Created by ipeerless on 02/02/2025.
//

import Foundation
import Supabase

@Observable
final class SupabaseService {
//    static let shared = SupabaseService() // Singleton instance
    
    private let client: SupabaseClient
    
    init() {
        let url = "https://gvcdqvmkugtepggoeyna.supabase.co"
        let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2Y2Rxdm1rdWd0ZXBnZ29leW5hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg1MjY0MjIsImV4cCI6MjA1NDEwMjQyMn0.kXlloyafZXzfu8he5iV8fZmrOaO1NZPogYfBRan4b6w"
        client = SupabaseClient(supabaseURL: URL(string: url)!, supabaseKey: apiKey)
    }
    
    /// Fetches all tasks from Supabase
    func fetchTasks() async -> Result<[TaskModel], Error> {
        do {
            let response: [TaskDTO] = try await client.from("tasks").select().execute().value
            let tasks = response.map { TaskModel(id: $0.id, title: $0.title, isCompleted: $0.isCompleted) }
            return .success(tasks)
        } catch {
            return .failure(error)
        }
    }
    
    /// Adds a new task to Supabase
    func addTask(_ task: TaskModel) async -> Result<Void, Error> {
        let taskDTO = TaskDTO(id: task.id, title: task.title, isCompleted: task.isCompleted)
        do {
            _ = try await client.from("tasks").insert([taskDTO]).execute()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

/// Task Data Transfer Object (DTO) for Supabase
struct TaskDTO: Codable {
    let id: String
    let title: String
    let isCompleted: Bool
}
