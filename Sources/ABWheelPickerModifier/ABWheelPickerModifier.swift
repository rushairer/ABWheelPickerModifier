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
    @Published public fileprivate(set) var displayAngle: Int = 0
    @Published public var minimumAngle: Int = 0
    @Published public var maximumAngle: Int = 360

    @Published fileprivate(set) var realAngle: CGFloat = 0
    @Published fileprivate(set) var lastAngle: CGFloat = 0
    @Published fileprivate(set) var virtualAngle: CGFloat = 0
    @Published fileprivate(set) var roundedNumber: CGFloat = 0
    
    private var initAngle: Int = 0
    
    public init(initAngle:Int = 0) {
        self.initAngle = initAngle
        self.reset()
    }
    
    public func reset() {
        self.lastAngle = CGFloat(self.initAngle)
        self.realAngle = self.lastAngle
        self.virtualAngle = self.realAngle
        self.displayAngle = self.initAngle
        
        self.roundedNumber = (self.realAngle - self.realAngle.truncatingRemainder(dividingBy: 360.0)) / 360.0
    }
}

@available(OSX 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)

public struct ABWheelPickerModifier: ViewModifier {
    @ObservedObject var data: ABWheelPickerModifierData
    
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
                    
                    var theta = (atan2(value.location.x - geometry.size.width / 2, geometry.size.width / 2 - value.location.y) - atan2(value.startLocation.x - geometry.size.width / 2, geometry.size.width / 2 - value.startLocation.y)) * 180 / .pi
                    
                    let predictedTheta = (atan2(value.predictedEndLocation.x - geometry.size.width / 2, geometry.size.width / 2 - value.predictedEndLocation.y) - atan2(value.location.x - geometry.size.width / 2, geometry.size.width / 2 - value.location.y)) * 180 / .pi
                    
                    if theta < 0 { theta += 360  }
                    
                    let fixedTheta = (self.data.lastAngle + theta).truncatingRemainder(dividingBy: 360.0)
                    let mod = self.data.realAngle.truncatingRemainder(dividingBy: 360.0)
                    
                    //var roundedNumberVariation: CGFloat = 0
                    
                    if predictedTheta > 0 && predictedTheta < 100 ||  predictedTheta < -300{
                        if mod >= 300 && mod <= 360 && fixedTheta >= 0 && fixedTheta <= 60 {
                            self.data.roundedNumber += 1
                            //roundedNumberVariation = 1
                        }
                    } else if predictedTheta < 0 && predictedTheta > -100 || predictedTheta > 300 {
                        if fixedTheta >= 300 && fixedTheta <= 360 && mod >= 0 && mod <= 60 {
                            self.data.roundedNumber -= 1
                            //roundedNumberVariation = -1
                        }
                    }
                    
                    self.data.realAngle = round(theta + self.data.lastAngle)
                    self.data.displayAngle = Int(round(fixedTheta + 360.0 * self.data.roundedNumber))
                    /*
                    //Check
                    let newAngle = Int(round(fixedTheta + 360.0 * (self.data.roundedNumber + roundedNumberVariation)))
                    
                    /*
                    guard newAngle <= self.data.maximumAngle else {
                        self.data.realAngle = CGFloat(self.data.maximumAngle)
                        return
                    }
                    guard newAngle >= self.data.minimumAngle else {
                        self.data.realAngle = CGFloat(self.data.minimumAngle)
                        return
                    }
                    */
                    print(newAngle)

                    self.data.virtualAngle = round(theta + self.data.lastAngle)
                    self.data.roundedNumber += roundedNumberVariation

                    self.data.realAngle = self.data.virtualAngle
                    self.data.displayAngle = newAngle
                    
                    if newAngle <= self.data.maximumAngle && newAngle >= self.data.minimumAngle {
                        
                    } else {
                        return
                    }
                    */
                    if self.dragGestureOnChanged != nil {
                        self.dragGestureOnChanged!(value)
                    }
                }
                .onEnded { value in
                    self.data.lastAngle = self.data.realAngle
                    /*
                    self.data.virtualAngle = self.data.realAngle
                    self.data.roundedNumber = (self.data.realAngle - self.data.realAngle.truncatingRemainder(dividingBy: 360.0)) / 360.0
                    */
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
