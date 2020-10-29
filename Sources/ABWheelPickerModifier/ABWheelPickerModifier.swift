//
//  WheelPickerModifier.swift
//  WheelPickerModifier
//
//  Created by Abenx on 2020/10/28.
//

import SwiftUI

@available(OSX 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)

public class ABWheelPickerModifierData: ObservableObject {
    @Published public fileprivate(set) var displayAngle: CGFloat = 0
    @Published public var minimumAngle: Int = 0
    @Published public var maximumAngle: Int = 360

    @Published fileprivate(set) var realAngle: CGFloat = 0
    @Published fileprivate(set) var lastAngle: CGFloat = 0
    @Published fileprivate(set) var lastPoint: CGPoint = CGPoint.zero
    
    private var initAngle: CGFloat = 0
    
    public init(initAngle:CGFloat = 0) {
        self.initAngle = initAngle
        self.reset()
    }
    
    public func reset() {
        self.lastAngle = CGFloat(self.initAngle)
        self.realAngle = self.lastAngle
        self.displayAngle = self.initAngle
        self.lastPoint = CGPoint.zero
    }
}

@available(OSX 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)

public struct ABWheelPickerModifier: ViewModifier {
    
    enum Direction {
        case none
        case clockwise
        case counterclockwise
    }
    
    @ObservedObject var data: ABWheelPickerModifierData
    
    @State private var direction: Direction = .none
    @State private var lastDirection: Direction = .none

    public var longPressGestureOnChanged: ((LongPressGesture.Value) -> Void)?
    public var longPressGestureOnEnded: ((LongPressGesture.Value) -> Void)?
    public var dragGestureOnChanged: ((DragGesture.Value) -> Void)?
    public var dragGestureOnEnded: ((DragGesture.Value) -> Void)?
    
    public init(_ data: ABWheelPickerModifierData,
                longPressGestureOnChanged: ((LongPressGesture.Value) -> Void)?,
                longPressGestureOnEnded: ((LongPressGesture.Value) -> Void)?,
                dragGestureOnChanged: ((DragGesture.Value) -> Void)?,
                dragGestureOnEnded: ((DragGesture.Value) -> Void)?
    ) {
        self.data = data
        self.longPressGestureOnChanged = longPressGestureOnChanged
        self.longPressGestureOnEnded = longPressGestureOnEnded
        self.dragGestureOnChanged = dragGestureOnChanged
        self.dragGestureOnEnded = dragGestureOnEnded
    }
    
    public func body(content: Content) -> some View {
        func internalView(geometry: GeometryProxy) -> some View {
            let pressGesture = LongPressGesture()
                .onChanged({ value in
                    if self.longPressGestureOnChanged != nil {
                        self.longPressGestureOnChanged!(value)
                    }
                })
                .onEnded { value in
                    if self.longPressGestureOnEnded != nil {
                        self.longPressGestureOnEnded!(value)
                    }
                }
            
            let dragGesture = DragGesture()
                .onChanged{ value in
                    let theta = (atan2(value.location.x - geometry.size.width / 2, geometry.size.width / 2 - value.location.y) - atan2(value.startLocation.x - geometry.size.width / 2, geometry.size.width / 2 - value.startLocation.y)) * 180 / .pi
                    
                    if self.data.lastPoint == CGPoint.zero {
                        self.data.lastPoint = value.startLocation
                    }
                    
                    var offsetTheta = (atan2(value.location.x - geometry.size.width / 2, geometry.size.width / 2 - value.location.y) - atan2(self.data.lastPoint.x - geometry.size.width / 2, geometry.size.width / 2 - self.data.lastPoint.y)) * 180 / .pi
                    
                    if offsetTheta < -90 {
                        offsetTheta += 360
                    }
                    
                    if offsetTheta > 90 {
                        offsetTheta -= 360
                    }
                    
                    self.data.displayAngle += offsetTheta
                    self.data.realAngle = round(theta + self.data.lastAngle)
                    
                    self.data.lastPoint = value.location
                    
                    if self.dragGestureOnChanged != nil {
                        self.dragGestureOnChanged!(value)
                    }
                }
                .onEnded { value in
                    self.data.lastAngle = self.data.realAngle
                    self.data.lastPoint = CGPoint.zero
                    
                    if self.dragGestureOnEnded != nil {
                        self.dragGestureOnEnded!(value)
                    }
                }
            
            let combined = pressGesture.simultaneously(with: dragGesture)
            
            return content
                .rotationEffect(.degrees(Double(self.data.realAngle)))
                .gesture(combined)
        }
        
        return GeometryReader(content: internalView(geometry:))
    }
}
