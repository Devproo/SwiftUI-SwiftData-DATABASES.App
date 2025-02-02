//
//  ContentView.swift
// SwiftDataAmplifyApp.App
//
//  Created by ipeerless on 28/01/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var tasks: [Task]
    
    @State private var newTaskTitle = ""
    @State var taskService = TaskService()

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(tasks) {  task in
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
                    Button("Add task") {
                        AddTask()
                    }
                }
                .padding()
            }
            .navigationTitle("Tasks")
            .task {
            await    loadTasksFromAmplify()
            }
        }
    }
    private  func AddTask() {
        guard  !newTaskTitle.isEmpty else {return}
        
        let newTask = Task(title: newTaskTitle)
        modelContext.insert(newTask)
        Task {
            do {
                try await taskService.saveTaskToAmplify(newTask)
            } catch {
                print("Failed to save task to Amplify: \(error)")
            }
        }
        newTaskTitle = ""
    }
    private func loadTasksFromAmplify() async {
        
        do {
            let amplifyTasks = try await taskService.fetchTasksFromAmplify()
            for task in amplifyTasks where !tasks.contains(where: {$0.id == task.id}) {
                modelContext.insert(task)
            }
        } catch {
            print("Failed to fetch tasks from Amplify: \(error)")
        }
    }
        
  
}

#Preview {
    ContentView()
}
