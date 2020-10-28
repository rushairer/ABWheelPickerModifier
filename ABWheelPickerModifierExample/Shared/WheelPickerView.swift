//
//  ContentView.swift
//  Shared
//
//  Created by Abenx on 2020/10/28.
//

import SwiftUI
import ABWheelPickerModifier

struct WheelPickerView: View {
    @ObservedObject var wheelPickerModifierData = ABWheelPickerModifierData()
    
    @State private var isActive: Bool = false {
        didSet {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            #endif
        }
    }
    
    var body: some View {
        func internalView(geometry: GeometryProxy) -> some View {
            return VStack(spacing: 20) {
                Text("\(self.wheelPickerModifierData.displayAngle)")
                ZStack {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: geometry.size.width, height: geometry.size.width, alignment: .center)
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .frame(
                                width: geometry.size.width/5,
                                height: geometry.size.width/5,
                                alignment: .center
                            )
                            .offset(x: geometry.size.width * 0.36, y: 0)
                    }
                    
                    .scaleEffect(self.isActive ? 1.2 : 1)
                    .modifier(ABWheelPickerModifier(wheelPickerModifierData,
                                                    longPressGestureOnChanged: { _ in
                                                        
                                                        withAnimation {
                                                            self.isActive = true
                                                        }
                                                    }, longPressGestureOnEnded: { _ in
                                                        
                                                        withAnimation {
                                                            self.isActive = false
                                                        }
                                                    }, dragGestureOnChanged: { _ in
                                                        withAnimation {
                                                            self.isActive = true
                                                        }
                                                        
                                                    }, dragGestureOnEnded: { _ in
                                                        withAnimation {
                                                            self.isActive = false
                                                        }
                                                        
                                                    }))
                    .frame(width: geometry.size.width, height: geometry.size.width, alignment: .center)
                    
                    Circle()
                        .fill(Color.accentColor.opacity(0.8))
                        .frame(width: geometry.size.width * 0.45, height: geometry.size.width * 0.45, alignment: .center)
                        .onTapGesture(count: 2) {
                            self.wheelPickerModifierData.reset()
                            self.isActive = false
                            #if os(iOS)
                            
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                        }
                }
            }
            .shadow(color: Color.black.opacity(0.25),
                     radius: 10,
                     x: 0,
                     y: 5)
        }
        return GeometryReader(content: internalView(geometry:))
    }
}

struct WheelPickerView_Previews: PreviewProvider {
    static var previews: some View {
        WheelPickerView()
            .padding(100)
            .accentColor(.pink)
    }
}
