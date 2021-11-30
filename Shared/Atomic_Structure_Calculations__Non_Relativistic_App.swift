//
//  Atomic_Structure_Calculations__Non_Relativistic_App.swift
//  Shared
//
//  Created by Jeff Terry on 11/28/21.
//

import SwiftUI

@main
struct Atomic_Structure_Calculations__Non_Relativistic_App: App {
    
    @StateObject var plotDataModel = PlotDataClass(fromLine: true)
    
    var body: some Scene {
        WindowGroup {
            TabView {
                            ContentView()
                                .environmentObject(plotDataModel)
                                .tabItem {
                                    Text("Plot")
                                }
                            TextView()
                                .environmentObject(plotDataModel)
                                .tabItem {
                                    Text("Text")
                                }
                                        
                                        
                        }
        }
    }
}
