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
    
    /// The value of the wheel.
    @Published public fileprivate(set) var value: CGFloat = 0
    
    /// The minimum value of the wheel.
    @Published public var minimumValue: Int = 0
    
    /// The maximum value of the wheel.
    @Published public var maximumValue: Int = 360
    
    /// The step value must be between 0 and 60.
    @Published public var step: CGFloat = 0 {
        didSet {
            assert(step <= 60 && step >= 0, "The step value must be between 0 and 60.")
        }
    }

    @Published fileprivate(set) var realAngle: CGFloat = 0
    @Published fileprivate(set) var lastAngle: CGFloat = 0
    @Published fileprivate(set) var lastPoint: CGPoint = CGPoint.zero
    
    private var initValue: CGFloat = 0
    
    public init(initValue:CGFloat = 0) {
        self.initValue = initValue
        self.reset()
    }
    
    public func reset() {
        self.lastAngle = CGFloat(self.initValue)
        withAnimation {
            self.realAngle = self.lastAngle
        }
        self.value = self.initValue
        self.lastPoint = CGPoint.zero
    }
    
    public func setRange(_ minimumValue: Int, _ maximumValue: Int) -> ABWheelPickerModifierData {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        return self
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
    @State private var pauseDragging = false
    
    public var dragGestureOnChanged: ((DragGesture.Value) -> Void)?
    public var dragGestureOnEnded: ((DragGesture.Value) -> Void)?
    public var minimumValueOnChanged: ((DragGesture.Value) -> Void)?
    public var maximumValueOnChanged: ((DragGesture.Value) -> Void)?

    public init(_ data: ABWheelPickerModifierData,
                dragGestureOnChanged: ((DragGesture.Value) -> Void)? = nil,
                dragGestureOnEnded: ((DragGesture.Value) -> Void)? = nil,
                minimumValueOnChanged: ((DragGesture.Value) -> Void)? = nil,
                maximumValueOnChanged: ((DragGesture.Value) -> Void)? = nil
    ) {
        self.data = data
        self.dragGestureOnChanged = dragGestureOnChanged
        self.dragGestureOnEnded = dragGestureOnEnded
        self.minimumValueOnChanged = minimumValueOnChanged
        self.maximumValueOnChanged = maximumValueOnChanged
    }
    
    public func body(content: Content) -> some View {
        func internalView(geometry: GeometryProxy) -> some View {
            let dragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged{ value in
                    assert(self.data.value >= CGFloat(self.data.minimumValue) && self.data.value <= CGFloat(self.data.maximumValue), "The value must be between minimumValue and maximumValue.")
                    
                    guard !self.pauseDragging else { return }

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
                    
                    guard offsetTheta > self.data.step || offsetTheta < -self.data.step else { return }
                    if self.data.step != 0 {
                        offsetTheta = offsetTheta - offsetTheta.truncatingRemainder(dividingBy: self.data.step)
                    }
                    
                    let virtualAngle = self.data.value + offsetTheta
                    
                    if virtualAngle > CGFloat(self.data.maximumValue) {
                        if self.maximumValueOnChanged != nil {
                            self.maximumValueOnChanged!(value)
                        }
                        self.data.value = CGFloat(self.data.maximumValue)
                        self.data.realAngle = self.data.value
                        self.pauseDragging = true
                    } else if virtualAngle < CGFloat(self.data.minimumValue) {
                        if self.minimumValueOnChanged != nil {
                            self.minimumValueOnChanged!(value)
                        }
                        self.data.value = CGFloat(self.data.minimumValue)
                        self.data.realAngle = self.data.value
                        self.pauseDragging = true
                    } else {
                        self.data.value += offsetTheta
                        
                        if self.data.step == 0 {
                            self.data.realAngle = round(theta + self.data.lastAngle)
                        } else {
                            self.data.realAngle = self.data.value
                        }
                        
                        self.data.lastPoint = value.location
                        
                        if self.dragGestureOnChanged != nil {
                            self.dragGestureOnChanged!(value)
                        }
                    }
                }
                .onEnded { value in
                    self.pauseDragging = false
                    
                    self.data.lastAngle = self.data.realAngle
                    self.data.lastPoint = CGPoint.zero
                    
                    if self.dragGestureOnEnded != nil {
                        self.dragGestureOnEnded!(value)
                    }
                }
                        
            return content
                .rotationEffect(.degrees(Double(self.data.realAngle)))
                .gesture(dragGesture)
        }
        
        return GeometryReader(content: internalView(geometry:))
    }
}
