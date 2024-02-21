//
//  ContentView.swift
//  Shared
//
//  Created by Angela on 2/21/24.
//  NOTES: Initial User Interface
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var activeEnergy: Double = 0
    @State private var exerciseTime: TimeInterval = 0
    @State private var standHours: Int = 0
    
    let healthStore = HKHealthStore()
    
    var body: some View {
        VStack {
            Text("Active Energy: \(activeEnergy, specifier: "%.2f") kcal")
            Text("Exercise Time: \(exerciseTime, specifier: "%.2f") seconds")
            Text("Stand Hours: \(standHours)")
        }
        .padding()
        .onAppear {
            requestAuthorization()
        }
    }
    
    private func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.categoryType(forIdentifier: .appleStandHour)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                fetchRingData()
            } else {
                print("HealthKit authorization denied.")
            }
        }
    }
    
    private func fetchRingData() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let exerciseTimeType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        let standHourType = HKObjectType.categoryType(forIdentifier: .appleStandHour)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let activeEnergyQuery = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch active energy data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
            }
        }
        
        let exerciseTimeQuery = HKStatisticsQuery(quantityType: exerciseTimeType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch exercise time data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                exerciseTime = sum.doubleValue(for: HKUnit.second())
            }
        }
        
        let standHourQuery = HKStatisticsQuery(categoryType: standHourType, predicate: predicate, options: .cumulativeSum) { query, result, error in
            guard let result = result else {
                print("Failed to fetch stand hour data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                standHours = Int(result.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        }
        
        healthStore.execute(activeEnergyQuery)
        healthStore.execute(exerciseTimeQuery)
        healthStore.execute(standHourQuery)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/*
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
*/
