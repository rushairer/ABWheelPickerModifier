//
//  ContentView.swift
//  watchOS Extension
//
//  Created by Abenx on 2020/10/28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        WheelPickerView()
            .frame(width: 100, height: 100, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
