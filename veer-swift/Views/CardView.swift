// CardView.swift
import SwiftUI

struct CardView: View {
    var card: Entrepreneur
    @Binding var forcedSwipe: CGFloat?
    var onSwiped: () -> Void
    var onMatch: (String) -> Void

    @State private var translation: CGSize = .zero

    private var expertiseTags: [String] {
        card.expertise.components(separatedBy: " · ")
    }

    var body: some View {
        ZStack {
            // ─── Background ─────────────────────────────
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

            VStack(spacing: 12) {
                Spacer().frame(height: 40)

                // ─── Name & Info ─────────────────────────
                Text(card.name)
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text(card.tagline)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text(card.company)
                    .font(.headline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text("Funding: \(card.funding)")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.purple)
                    .multilineTextAlignment(.center)

                Text(card.bio)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // ─── Expertise & Looking for ─────────────
                expertiseSection
                lookingForSection

                // Push slider and bottom content down
                Spacer()

                // ─── Match Score Slider ──────────────────
                matchScoreSlider

                Spacer(minLength: 0)
            }
            .padding(20)

            // ─── LIKE/NOPE Overlay ────────────────────
            likeNopeOverlay
        }
        .frame(width: UIScreen.main.bounds.width - 32,
               height: 520)
        .overlay(avatarOverlay, alignment: .top)
        .offset(x: translation.width)
        .rotationEffect(.degrees(rotationAngle), anchor: .bottom)
        .gesture(dragGesture)
        .onChange(of: forcedSwipe) { newValue in
            guard let x = newValue else { return }
            withAnimation(.easeInOut) { translation.width = x }
            scheduleRemoval()
        }
    }

    // MARK: — Subviews

    private var expertiseSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(expertiseTags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.2))
                        .foregroundColor(.purple)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var lookingForSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(card.lookingFor, id: \.self) { need in
                    Text(need)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // ─── matchScoreSlider ─────────────────────────────────────────
    private var matchScoreSlider: some View {
        GeometryReader { geo in
            let totalW: CGFloat   = geo.size.width
            let sidePad: CGFloat  = 16         // matches .padding(.horizontal,16)
            let iconW: CGFloat    = 16         // your icon frames
            let thumbW: CGFloat   = 32         // diameter of our custom thumb
            
            // full “track” under the slider (between icons)
            let trackW = totalW - (sidePad*2 + iconW*2)
            // how far the thumb can actually move
            let movementW = trackW - thumbW
            
            // fraction from 0→1
            let frac = CGFloat(card.matchScore - 1) / 9.0
            
            // center of thumb at minimum (score=1)
            let startX = -totalW/2
                         + sidePad
                         + iconW
                         + thumbW/2
            
            // final offset
            let xOffset = startX + frac * movementW
            
            ZStack {
                HStack(spacing: 8) {
                    Image(systemName: "thermometer.snowflake")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: iconW, height: iconW)
                    
                    Slider(value: .constant(Double(card.matchScore)),
                           in: 1...10,
                           step: 1)
                        .disabled(true)
                        .accentColor(.purple)
                    
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: iconW, height: iconW)
                }
                .padding(.horizontal, sidePad)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: thumbW, height: thumbW)
                    .shadow(radius: 2)
                    .overlay(
                        Text("\(card.matchScore)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                    )
                    .offset(x: xOffset)
            }
        }
        .frame(height: 44)
    }


    private var avatarOverlay: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 90, height: 90)
                .shadow(radius: 5)
            Image(card.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
        }
        .offset(y: -45)
    }

    private var likeNopeOverlay: some View {
        VStack {
            HStack {
                if translation.width > 0 {
                    statusLabel("LIKE", color: .green)
                    Spacer()
                } else if translation.width < 0 {
                    Spacer()
                    statusLabel("NOPE", color: .red)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            Spacer()
        }
    }

    // MARK: — Helpers

    private var rotationAngle: Double {
        Double(translation.width / (UIScreen.main.bounds.width - 32)) * 12
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { translation = $0.translation }
            .onEnded { _ in performSwipeLogic() }
    }

    private func performSwipeLogic() {
        withAnimation(.easeInOut) {
            if translation.width > 150 {
                translation.width = 600
                onMatch(card.name)
                scheduleRemoval()
            } else if translation.width < -150 {
                translation.width = -600
                onSwiped()
                scheduleRemoval()
            } else {
                translation = .zero
            }
        }
    }

    private func scheduleRemoval() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSwiped()
            translation = .zero
        }
    }

    private func statusLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(color, lineWidth: 2)
            )
    }
}
