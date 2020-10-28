//
//  ContentView.swift
//  ABWheelPickerModifierExample (macOS)
//
//  Created by Abenx on 2020/10/28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack(spacing: 40) {
            WheelPickerView()
                .frame(width: 100, height: 100, alignment: .center)

            WheelPickerView()
                .frame(width: 100, height: 100, alignment: .center)

        }
        .frame(width: 800, height: 600, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
