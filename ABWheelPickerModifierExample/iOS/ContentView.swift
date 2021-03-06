//
//  ContentView.swift
//  ABWheelPickerModifierExample (iOS)
//
//  Created by Abenx on 2020/10/28.
//

import SwiftUI
import ABWheelPickerModifier

struct ContentView: View {
    var wheelPickerModifierData = ABWheelPickerModifierData(initValue: 320)
    
    var body: some View {
        self.wheelPickerModifierData.minimumValue = Int(30 * 5.5)
        self.wheelPickerModifierData.maximumValue = Int(250 * 5.5)
        self.wheelPickerModifierData.step = 5.5
        return VStack(spacing: 80) {
            Image(systemName: "timelapse")
                .resizable()
                .modifier(ABWheelPickerModifier(ABWheelPickerModifierData().setRange(-3600, 3600), dragGestureOnChanged: { _ in
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }))
                .frame(width: 80, height: 80, alignment: .center)

            WheelPickerView(wheelPickerModifierData: self.wheelPickerModifierData)
                .frame(width: 180, height: 180, alignment: .center)
                .padding()

            WheelPickerView()
                .frame(width: 120, height: 120, alignment: .center)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
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
