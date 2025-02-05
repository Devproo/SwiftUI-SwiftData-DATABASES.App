//
//  PostgresServiceNIO.swift
//  SwiftUI+SwiftData+DATABASES.App
//
//  Created by ipeerless on 04/02/2025.
//
import Foundation
@preconcurrency import PostgresNIO
import NIOCore
import NIOPosix
import Logging

@Observable

class PostgresServiceNIO {
    private var connection: PostgresConnection?
    private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    init() {
        Task {
            await connectToDatabase()
        }
    }
    
    deinit {
        try? eventLoopGroup.syncShutdownGracefully()
    }
    
    private func connectToDatabase() async {
        do {
            let configuration = PostgresConnection.Configuration(
                host: "localhost",
                port: 5432,
                username: "your_username",
                password: "your_password",
                database: "your_database",
                tls: .disable // or .require if your database uses TLS
            )
            
            let logger = Logger(label: "PostgresServiceNIO") // Add logger
            let conn = try await PostgresConnection.connect(
                on: eventLoopGroup.next(),
                configuration: configuration,
                id: 1, // Provide an integer ID (e.g., 1)
                logger: logger // Pass logger
                
            )
            
            self.connection = conn
            print("Connected to PostgreSQL successfully!")
        } catch {
            print("Failed to connect to PostgreSQL: \(error)")
        }
    }
    
   func fetchTasks() async throws -> [TaskModel] {
        guard let connection = connection else {
            throw DatabaseErrorNio.connectionNotAvailable
        }

        let query = "SELECT id, title, isCompleted FROM tasks"

        let result = try await Task.detached {
            try await connection.query(query).get()
        }.value  // Ensures the result is retrieved safely

        let rows = result.rows

        return try rows.map { row in
            let randomAccessRow = row.makeRandomAccess()
            
            guard let id = randomAccessRow[data: "id"].string,
                  let title = randomAccessRow[data: "title"].string,
                  let isCompleted = randomAccessRow[data: "isCompleted"].bool else {
                throw DatabaseErrorNio.invalidData
            }
            
            return TaskModel(
                id: id,
                title: title,
                isCompleted: isCompleted
            )
        }
    }

    
    
    
    func saveTask(_ task: TaskModel) async throws {
        guard let connection else { throw DatabaseErrorNio.connectionNotAvailable }
        
        let query = "INSERT INTO tasks (id, title, isCompleted) VALUES ($1, $2, $3)"
        _ =  connection.query(
            query,
            [
                PostgresData(string: task.id),
                PostgresData(string: task.title),
                PostgresData(bool: task.isCompleted)
            ]
        )
    }
    
    
    func updateTask(_ task: TaskModel) async throws {
        guard let connection else { throw DatabaseErrorNio.connectionNotAvailable }
        
        let query = "UPDATE tasks SET title = $1, isCompleted = $2 WHERE id = $3"
        _ = connection.query(
            query,
            [
                PostgresData(string: task.title),
                PostgresData(bool: task.isCompleted),
                PostgresData(string: task.id)
            ]
        )
    }
    
    func deleteTask(_ task: TaskModel) async throws {
        guard let connection else { throw DatabaseErrorNio.connectionNotAvailable }
        
        let query = "DELETE FROM tasks WHERE id = $1"
        _  = connection.query(
            query,
            [PostgresData(string: task.id)]
        )
    }
    
}

// Custom Error Handling
enum DatabaseErrorNio: Error {
    case connectionNotAvailable
    case invalidData
}

