//
//  ContentView.swift
//  SwiftUI+SwiftData+DATABASES.App
//
//  Created by ipeerless on 28/01/2025.
//
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ContentView: View {
    @State private var tasks: [TaskModel] = []
    @State private var newTaskTitle = ""
    private var db = Firestore.firestore()

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
                await loadTasksFromFirestore()
            }
        }
    }

    func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        
        let newTask = Task(title: newTaskTitle, isCompleted: false)

        // Save new task to Firebase Firestore
        db.collection("tasks").addDocument(data: [
            "title": newTask.title,
            "isCompleted": newTask.isCompleted
        ]) { error in
            if let error = error {
                print("Error adding task: \(error)")
            } else {
                // Task successfully added
                self.newTaskTitle = ""
            }
        }
    }

    func toggleTaskCompletion(_ task: Task) {
        let updatedTask = task
        updatedTask.isCompleted.toggle()
        
        // Update task in Firestore
        if let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
            db.collection("tasks").document(task.id).updateData([
                "isCompleted": updatedTask.isCompleted
            ]) { error in
                if let error = error {
                    print("Error updating task: \(error)")
                } else {
                    tasks[taskIndex] = updatedTask
                }
            }
        }
    }

    func loadTasksFromFirestore() async {
        db.collection("tasks").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting tasks: \(error)")
            } else {
                tasks = snapshot?.documents.compactMap { document in
                    try? document.data(as: Task.self)
                } ?? []
            }
        }
    }
}

#Preview {
    ContentView()
}
