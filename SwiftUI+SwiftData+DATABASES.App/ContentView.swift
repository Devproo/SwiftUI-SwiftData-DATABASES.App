//
//  ContentView.swift
//  SwiftUI+SwiftData+DATABASES.App
//
//  Created by ipeerless on 28/01/2025.
//
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskModel]
    
    @State private var newTaskTitle = ""
    @State var supabaseService = SupabaseService()
    
    var body: some View {
        NavigationStack {
            VStack {
                List(tasks, id: \.id) { task in
                    HStack {
                        Text(task.title)
                        Spacer()
                        if task.isCompleted {
                            Image(systemName: "checkmark.circle")
                        }
                    }
                }
                
                HStack {
                    TextField("Add task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Add", action: addTask)
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Tasks")
            .task {
                await loadTasksFromSupabase()
            }
        }
        .task {
            await loadTasksFromSupabase()
        }
    }
    
    /// Adds a new task both locally and in Supabase
    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        
        let newTask = TaskModel(id: UUID().uuidString, title: newTaskTitle, isCompleted: false)
        modelContext.insert(newTask)
        
        Task {
            let result = await supabaseService.addTask(newTask)
            if case .failure(let error) = result {
                print("Failed to save task to Supabase: \(error)")
            }
        }
        
        newTaskTitle = ""
    }
    
    /// Loads tasks from Supabase and inserts them into SwiftData
    private func loadTasksFromSupabase() async {
        let result = await supabaseService.fetchTasks()
        
        switch result {
        case .success(let fetchedTasks):
            for task in fetchedTasks where !tasks.contains(where: { $0.id == task.id }) {
                modelContext.insert(task)
            }
        case .failure(let error):
            print("Failed to fetch tasks from Supabase: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
