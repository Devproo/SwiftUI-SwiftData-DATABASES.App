//
//  AppWriteService.swift
//  SwiftUI+SwiftData+DATABASES.App
//
//  Created by ipeerless on 03/02/2025.
//

import Foundation
import Appwrite

@Observable
class AppWriteService {
    private let client: Client
    private let database: Databases
    private let tasksCollectionId: String
    private let databaseId: String
    
    init() {
        client = Client()
            .setEndpoint("https://cloud.appwrite.io/v1")
            .setProject("67a0af8300209fcba9cf")
        database = Databases(client)
        databaseId = "67a0b4ae00193cc955f7"
        tasksCollectionId = "67a0b4b800294ea30f8d"
    }
    
    func fetchTasks() async throws -> [TaskModel] {
        let documentList = try await database.listDocuments(
            databaseId: databaseId,
            collectionId: tasksCollectionId
        )
        
        let tasks = documentList.documents as? [[String: Any]] ?? []
        
        return tasks.compactMap { task in
            guard let id = task["id"] as? String,
                  let title = task["title"] as? String,
                  let isCompleted = task["isCompleted"] as? Bool else { return nil }
            return TaskModel(id: id, title: title, isCompleted: isCompleted)
        }

    }
    
    func saveTask(_ task: TaskModel) async throws {
        let document  = try await database.createDocument(databaseId: databaseId, collectionId: tasksCollectionId, documentId: task.id, data: [
            "id": task.id,
            "title": task.title,
            "isCompleted": task.isCompleted
        ])
        print("Task saved to Appwrite with ID: \(document.id)")
    }

//    func saveTask(_ task: TaskModel) async throws {
//        let document = try await database.createDocument(
//            databaseId: databaseId,
//            collectionId: tasksCollectionId,
//            data: [
//                "id": task.id, // Include the UUID as a field
//                "title": task.title,
//                "isCompleted": task.isCompleted
//            ]
//        )
//        print("Task saved to Appwrite with ID: \(document.id)") // This will now be Appwrite's generated ID.
//    }
    
    func updateTask(_ task: TaskModel) async throws {
        let document  = try await database.updateDocument(databaseId: databaseId, collectionId: tasksCollectionId, documentId: task.id, data: [
            "title": task.title,
            "isCompleted": task.isCompleted
        ])
        print("Task updated to Appwrite with ID: \(document.id)")
    }
    
    func deleteTask(_ task: TaskModel) async throws {
        _  = try await database.deleteDocument(
               databaseId: databaseId,
               collectionId: tasksCollectionId,
               documentId: task.id
           )
           print("Task deleted from Appwrite with ID: \(task.id)")
       }
    
}
