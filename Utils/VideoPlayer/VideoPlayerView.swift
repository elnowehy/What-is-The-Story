//
//  VideoPlayerView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-29.
//

import SwiftUI
import AVKit
import CoreMotion

struct VideoPlayerView: View {
    @Binding var player: AVPlayer?
    @EnvironmentObject var theme: Theme
    @State private var isFullScreen = false
    @State private var orientation: UIDeviceOrientation?
    private let motionManager = CMMotionManager()
    
    var body: some View {
        
        VideoPlayer(player: player)
            .modifier(VideoPlayerStyle(theme: theme, isFullScreen: $isFullScreen))
            .onAppear {
                startDeviceMotionUpdates()
            }
            .onDisappear {
                stopDeviceMotionUpdates()
            }
            .onChange(of: orientation) { newValue in
                updateOrientation(newValue)
            }
        
            .background(theme.colors.primaryBackground)
    }
    
    private func startDeviceMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.2
            motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
                guard let motion = motion else { return }
                let deviceOrientation = motion.attitude.roll > 0 ? UIDeviceOrientation.landscapeLeft : UIDeviceOrientation.landscapeRight
                if deviceOrientation != self.orientation {
                    self.orientation = deviceOrientation
                }
            }
        }
    }
    
    private func stopDeviceMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    private func updateOrientation(_ newOrientation: UIDeviceOrientation?) {
        guard let newOrientation = newOrientation else { return }
        if newOrientation.isLandscape {
            isFullScreen = true
        } else {
            isFullScreen = false
        }
    }
}

//struct VideoPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoPlayerView()
//    }
//}
