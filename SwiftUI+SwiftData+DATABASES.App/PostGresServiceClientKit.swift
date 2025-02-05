//
//  PostGresServiceClientKit.swift
//  SwiftUI+SwiftData+DATABASES.App
//
//  Created by ipeerless on 04/02/2025.
//
import Foundation
import PostgresClientKit

@Observable
@MainActor
class PostGresServiceClientKit {
    private var connection: Connection?

    init() {
        do {
            var configuration = ConnectionConfiguration()
            configuration.host = "localhost"
            configuration.port = 5432
            configuration.database = "taskdb"
            configuration.user = "your_user"
            configuration.credential = .md5Password(password: "your_password")
            configuration.ssl = false // 👈 Disable SSL explicitly

            self.connection = try Connection(configuration: configuration)
        } catch {
            print("Failed to connect to PostgreSQL: \(error)")
        }
    }

    func fetchTasks() async throws -> [TaskModel] {
        guard let connection = connection else { throw DatabaseError.connectionFailed }
        var tasks: [TaskModel] = []
        let query = "SELECT id, title, isCompleted FROM tasks"

        do {
            let statement = try connection.prepareStatement(text: query)
            defer { statement.close() }

            for result in try statement.execute() {
                switch result {
                case .success(let row):
                    let id = try row.columns[0].string()
                    let title = try row.columns[1].string()
                    let isCompleted = try row.columns[2].bool()
                    tasks.append(TaskModel(id: id, title: title, isCompleted: isCompleted))
                case .failure(let error):
                    print("Error fetching row: \(error)")
                }
            }
        } catch {
            print("Error fetching tasks: \(error)")
        }

        return tasks
    }

    func saveTask(_ task: TaskModel) async throws {
        guard let connection = connection else { throw DatabaseError.connectionFailed }
        let query = "INSERT INTO tasks (id, title, isCompleted) VALUES ($1, $2, $3)"
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() }
        try statement.execute(parameterValues: [task.id, task.title, task.isCompleted])
    }

    func updateTask(_ task: TaskModel) async throws {
        guard let connection = connection else { throw DatabaseError.connectionFailed }
        let query = "UPDATE tasks SET title = $1, isCompleted = $2 WHERE id = $3"
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() }
        try statement.execute(parameterValues: [task.title, task.isCompleted, task.id])
    }

    func deleteTask(_ task: TaskModel) async throws {
        guard let connection = connection else { throw DatabaseError.connectionFailed }
        let query = "DELETE FROM tasks WHERE id = $1"
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() }
        try statement.execute(parameterValues: [task.id])
    }
}

enum DatabaseError: Error {
    case connectionFailed
}

