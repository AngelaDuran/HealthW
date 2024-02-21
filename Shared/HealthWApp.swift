//
//  HealthWApp.swift
//  Shared
//
//  Created by Angela on 2/21/24.
//

import SwiftUI

@main
struct HealthWApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
