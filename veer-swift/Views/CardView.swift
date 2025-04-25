// CardView.swift
import SwiftUI

struct CardView: View {
    var card: Entrepreneur
    @Binding var forcedSwipe: CGFloat?
    var onSwiped: () -> Void
    var onMatch: (String) -> Void

    @State private var translation: CGSize = .zero

    // Split out for performance
    private var expertiseTags: [String] {
        card.expertise.components(separatedBy: " · ")
    }

    var body: some View {
        ZStack {
            // Background uses Apple’s material
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

            VStack(spacing: 14) {
                Spacer().frame(height: 50)

                // 1) Name — uses .largeTitle
                Text(card.name)
                    .font(.largeTitle.weight(.semibold))
                    .multilineTextAlignment(.center)

                // 2) Tagline — .subheadline
                Text(card.tagline)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // 3) Company — .headline
                Text(card.company)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                // 4) Funding — .callout
                Text("Funding: \(card.funding)")
                    .font(.callout)
                    .foregroundColor(.purple)
                    .multilineTextAlignment(.center)

                // 5) Bio — .body
                Text(card.bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // 6) Expertise tags — .caption
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(expertiseTags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.purple.opacity(0.2))
                                .foregroundColor(.purple)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // 7) Looking for — .caption
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(card.lookingFor, id: \.self) { need in
                            Text(need)
                                .font(.caption)
                                .bold()
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // 8) Match score slider
                HStack(spacing: 12) {
                    Image(systemName: "thermometer.snowflake")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(
                        value: .constant(Double(card.matchScore)),
                        in: 1...10,
                        step: 1
                    )
                    .disabled(true)
                    .accentColor(.purple)

                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 0)
            }
            .padding(20)

            // LIKE / NOPE overlay
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

    // MARK: — Overlays & Helpers

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

    private func statusLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(color, lineWidth: 2)
            )
    }

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
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(
            card: sampleEntrepreneurs[2],
            forcedSwipe: .constant(nil),
            onSwiped: {},
            onMatch: { _ in }
        )
        .preferredColorScheme(.light)
    }
}
