import SwiftUI

struct TypingIndicator: View {
    @State private var opacity1: CGFloat = 0.3
    @State private var opacity2: CGFloat = 0.3
    @State private var opacity3: CGFloat = 0.3
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .frame(width: 6, height: 6)
                .opacity(opacity1)
            Circle()
                .frame(width: 6, height: 6)
                .opacity(opacity2)
            Circle()
                .frame(width: 6, height: 6)
                .opacity(opacity3)
        }
        .foregroundColor(.primary)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0)) {
                opacity1 = 1
            }
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.2)) {
                opacity2 = 1
            }
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.4)) {
                opacity3 = 1
            }
        }
    }
}
