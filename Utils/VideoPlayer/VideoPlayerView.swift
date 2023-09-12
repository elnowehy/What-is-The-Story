//
//  VideoPlayerView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-29.
//

import SwiftUI
import AVKit

struct PlayerView: UIViewControllerRepresentable {
    @Binding var player: AVPlayer

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
        playerController.player = player
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerController = AVPlayerViewController()
        playerController.player = player
        return playerController
    }
}

class PlayerVM: ObservableObject {
    @Published var player: AVPlayer?

    func preparePlayer(with url: URL) {
        player = AVPlayer(url: url)
    }
}


//struct VideoPlayerView: View {
//    @Binding var player: AVPlayer?
//    @EnvironmentObject var theme: Theme
//    @State private var isFullScreen = false
//
//    var body: some View {
//        ZStack(alignment: .bottomTrailing) {
//            VideoPlayer(player: player)
//                .modifier(VideoPlayerStyle(theme: theme, isFullScreen: $isFullScreen))
//                .background(theme.colors.primaryBackground)
//                .edgesIgnoringSafeArea(isFullScreen ? .all : .init())
//            Button(action: {
//                withAnimation {
//                    isFullScreen.toggle()
//                }
//            }) {
//                Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
//                    .resizable()
//                    .frame(width: 30, height: 30)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.black.opacity(0.7))
//                    .clipShape(Circle())
//            }
//            .padding(.all, 20)
//        }
//        .onAppear(perform: {
//            let value = UIInterfaceOrientation.landscapeRight.rawValue
//            UIDevice.current.setValue(value, forKey: "orientation")
//            UIViewController.attemptRotationToDeviceOrientation()
//        })
//        .onDisappear(perform: {
//            let value = UIInterfaceOrientation.portrait.rawValue
//            UIDevice.current.setValue(value, forKey: "orientation")
//            UIViewController.attemptRotationToDeviceOrientation()
//        })
//    }
//}


//struct VideoPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoPlayerView()
//    }
//}
