import SwiftUI
import AVKit

struct VideoPlayerView: View {
    var body: some View {
        VStack {
            VideoPlayer(player: AVPlayer(url: URL(string: "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4")!)) {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "play.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                            .padding(.bottom, 50)
                        Spacer()
                    }
                }
            }
            .frame(height: 300)
            .cornerRadius(10)
            .padding(.horizontal, GlobalTheme.spacing)
            .padding(.vertical, GlobalTheme.spacing)
            .background(GlobalTheme.backgroundColor)
            .theme()
        }
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView()
            .previewLayout(.sizeThatFits)
    }
}
