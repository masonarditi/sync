// CardView.swift
import SwiftUI

struct CardView: View {
    var card: Entrepreneur
    @Binding var forcedSwipe: CGFloat?
    var onSwiped: () -> Void
    var onMatch: (String) -> Void

    @State private var translation: CGSize = .zero

    // Pre-computed split for performance
    private var expertiseTags: [String] {
        card.expertise.components(separatedBy: " · ")
    }

    var body: some View {
        ZStack {
            background
            content
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

    private var background: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.regularMaterial)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var content: some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 50)

            Text(card.name)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(card.tagline)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text(card.company)
                .font(.headline.weight(.medium))
                .multilineTextAlignment(.center)

            Text("Funding: \(card.funding)")
                .font(.caption)
                .foregroundColor(.purple)
                .multilineTextAlignment(.center)

            Text(card.bio)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            expertiseSection
            lookingForSection
            matchScoreSection

            Spacer(minLength: 0)
        }
        .padding(20)
    }

    private var expertiseSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(expertiseTags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
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
            HStack(spacing: 12) {
                ForEach(card.lookingFor, id: \.self) { need in
                    Text(need)
                        .font(.caption2.weight(.bold))
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

    private var matchScoreSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "thermometer.snowflake")
                .foregroundColor(.secondary)
            Slider(
                value: .constant(Double(card.matchScore)),
                in: 1...10,
                step: 1
            )
            .disabled(true)
            .accentColor(.purple)
            Image(systemName: "flame.fill")
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
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
                translation.width = 600; onMatch(card.name); scheduleRemoval()
            } else if translation.width < -150 {
                translation.width = -600; onSwiped(); scheduleRemoval()
            } else {
                translation = .zero
            }
        }
    }

    private func scheduleRemoval() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSwiped(); translation = .zero
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
