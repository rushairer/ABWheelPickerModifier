//
//  ABWheelPickerModifierExampleApp.swift
//  Shared
//
//  Created by Abenx on 2020/10/28.
//

import SwiftUI

@main
struct ABWheelPickerModifierExampleApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(.white)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.8), Color.blue.opacity(0.9)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).edgesIgnoringSafeArea(.all))
        }
    }
}
