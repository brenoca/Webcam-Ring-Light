//
//  RingView.swift
//  Webcam Ring Light
//
//  Created by Breno Araujo on 29.10.2024.
//

import SwiftUI

struct ObservableRingView: View {
    @ObservedObject var windowManager: WindowManager
    
    var body: some View {
        GeometryReader { geometry in
            RingView(
                radiusPercentage: Binding(
                    get: { self.windowManager.radiusPercentage },
                    set: { self.windowManager.radiusPercentage = $0 }
                ),
                borderPercentage: Binding(
                    get: { self.windowManager.borderPercentage },
                    set: { self.windowManager.borderPercentage = $0 }
                ),
                screenSize: geometry.size
            )
        }
    }
}


struct RingView: View {
    @Binding var radiusPercentage: Double
    @Binding var borderPercentage: Double
    let screenSize: CGSize
    
    private var maxScreenDimension: CGFloat {
        max(screenSize.width, screenSize.height)
    }
    
    private var diameter: CGFloat {
        maxScreenDimension * (radiusPercentage / 100.0)
    }
    
    private var borderWidth: CGFloat {
        maxScreenDimension * (borderPercentage / 100.0)
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Circle()
                .strokeBorder(Color.white, lineWidth: borderWidth)
                .frame(width: diameter, height: diameter)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(width: screenSize.width, height: screenSize.height)
        .padding(0)
        .ignoresSafeArea()
    }
}
