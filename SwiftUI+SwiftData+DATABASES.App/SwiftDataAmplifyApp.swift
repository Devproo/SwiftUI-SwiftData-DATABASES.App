//
//  SwiftDataAmplifyApp.swift
//  SwiftDataAmplifyApp.App
//
//  Created by ipeerless on 28/01/2025.
//

import SwiftUI
import Amplify
import AmplifyPlugins
import SwiftData


@main
struct SwiftDataAmplifyApp: App {
    init() {
        configureAmplify()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Task.self])
        }
    }
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSDataStorePlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.configure()
            print("Amplify configured successfully")
        } catch {
            print("Failed to configure Amplify: \(error)")
        }
    }
}
