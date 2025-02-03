//
//  ContentView.swift
//  SwiftUI+SwiftData+DATABASES.App
//
//  Created by ipeerless on 28/01/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var tasks: [TaskModel]
    @State var newTaskTitle = ""
    @State var appWriteService = AppWriteService()
    
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
                           await loadTasksFromAppWrite()
                       }
                   }
               }
    
    func addTask() {
        guard !newTaskTitle.isEmpty else {return}
        
        let newTask = TaskModel(id: UUID().uuidString, title: newTaskTitle, isCompleted: false)
        modelContext.insert(newTask)
        Task {
            do {
                try await appWriteService.saveTask(newTask)
            } catch {
                print("Failed to save task to Appwrite: \(error)")
            }
        }
        newTaskTitle = ""
    }
    func toggleTaskCompletion(_ task: TaskModel) {
        if let index = tasks.firstIndex(where: {$0.id == task.id}) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func loadTasksFromAppWrite()  async {
        do {
            let appWriteTasks = try await appWriteService.fetchTasks()
           
            for task in appWriteTasks {
                modelContext.insert(task)
            }
        } catch  {
            print("Failed to fetch tasks from Appwrite: \(error)")
        }
    }
    
}

#Preview {
    ContentView()
}
