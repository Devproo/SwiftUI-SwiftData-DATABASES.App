//
//  ContentView.swift
//  SwiftUI+SwiftData+DATABASES.App
//
//  Created by ipeerless on 28/01/2025.
//
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var tasks: [TaskModel]
    @State var newTaskTitle = ""
    @State var postgresService = PostgresServiceNIO() // Use correct service name

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(tasks) { task in
                        HStack {
                            Text(task.title)
                            Spacer()
                            if task.isCompleted {
                                Image(systemName: "checkmark.circle")
                            }
                        }
                        .onTapGesture {
                            toggleTaskCompletion(task)
                        }
                    }
                }
                HStack {
                    TextField("Add task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        addTask()
                    }
                }
                .padding()
            }
            .navigationTitle("Tasks")
            .task {
                await loadTasksFromPostgres()
            }
        }
    }

    func addTask() {
        guard !newTaskTitle.isEmpty else { return }

        let newTask = TaskModel(id: UUID().uuidString, title: newTaskTitle, isCompleted: false)
        modelContext.insert(newTask)

        Task {
            do {
                try await postgresService.saveTask(newTask)
            } catch {
                print("Failed to save task to PostgreSQL: \(error)")
            }
        }
        newTaskTitle = ""
    }

    func toggleTaskCompletion(_ task: TaskModel) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()

        modelContext.insert(updatedTask) // Update in SwiftData

        Task {
            do {
                try await postgresService.updateTask(updatedTask)
            } catch {
                print("Failed to update task in PostgreSQL: \(error)")
            }
        }
    }

    func loadTasksFromPostgres() async {
        do {
            let postgresTasks = try await postgresService.fetchTasks()
            for task in postgresTasks {
                modelContext.insert(task)
            }
        } catch {
            print("Failed to fetch tasks from PostgreSQL: \(error)")
        }
    }
}

#Preview {
    ContentView()
}


//import SwiftUI
//import SwiftData
//
//struct ContentView: View {
//    @Environment(\.modelContext) var modelContext
//    @Query var tasks: [TaskModel]
//    @State var newTaskTitle = ""
//    @State var postgresServiceClientKit = PostGresServiceClientKit()
//    
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                List {
//                    ForEach(tasks) { task in
//                        HStack {
//                            Text(task.title)
//                            Spacer()
//                            if task.isCompleted {
//                                Image(systemName: "checkmark.circle")
//                            }
//                        }
//                    }
//                }
//                HStack {
//                    TextField("Add task", text: $newTaskTitle)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    Button("Add") {
//                        addTask()
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("Tasks")
//            .task {
//                await loadTasksFromPostgres()
//                
//            }
//        }
//    }
//    
//    func addTask() {
//        guard !newTaskTitle.isEmpty else { return }
//        
//        let newTask = TaskModel( id: UUID().uuidString, title: newTaskTitle, isCompleted: false)
//        modelContext.insert(newTask)
//        
//        Task {
//            do {
//                try  await postgresServiceClientKit.saveTask(newTask)
//            } catch {
//                print("Failed to save task to PostgreSQL: \(error)")
//            }
//        }
//        newTaskTitle = ""
//    }
//    
//    func toggleTaskCompletion(_ task: TaskModel) {
//        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
//            tasks[index].isCompleted.toggle()
//        }
//    }
//    
//    func loadTasksFromPostgres() async {
//        do {
//            let postgresTasks = try  await postgresServiceClientKit.fetchTasks()
//            for task in postgresTasks {
//                modelContext.insert(task)
//            }
//        } catch {
//            print("Failed to fetch tasks from PostgreSQL: \(error)")
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
//

