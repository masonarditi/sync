// CardView.swift
import SwiftUI

struct CardView: View {
    var card: Entrepreneur
    @Binding var forcedSwipe: CGFloat?
    var onSwiped: () -> Void
    var onMatch: (String) -> Void

    @State private var translation: CGSize = .zero

    // pre-split expertise for performance
    private var expertiseTags: [String] {
        card.expertise.components(separatedBy: " · ")
    }

    var body: some View {
        ZStack {
            background
            content
            likeNopeOverlay
        }
        .frame(
            width: UIScreen.main.bounds.width - 32,
            height: 540     // ← reduced from 620 to 540
        )
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

    // ─── Subviews ────────────────────────────────────────────────────────────────

    private var background: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color(white: 0.97))
            .shadow(radius: 5)
    }

    private var content: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 44)

            Text(card.name)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            Text(card.tagline)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Text(card.company)
                .font(.headline).bold()
                .multilineTextAlignment(.center)

            Text("Funding: \(card.funding)")
                .font(.callout)
                .foregroundColor(.purple)
                .multilineTextAlignment(.center)

            Text(card.bio)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            HStack(spacing: 12) {
                ForEach(expertiseTags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption).bold()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.purple.opacity(0.2))
                        .foregroundColor(.purple)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 12) {
                ForEach(card.lookingFor, id: \.self) { need in
                    Text(need)
                        .font(.caption2).bold()
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }

            HStack {
                Text("🥶")
                Slider(value: .constant(Double(card.matchScore)),
                       in: 1...10,
                       step: 1)
                    .disabled(true)
                    .accentColor(.purple)
                Text("🔥")
            }
            .padding(.horizontal, 16)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private var likeNopeOverlay: some View {
        VStack {
            HStack {
                if translation.width > 0 {
                    statusLabel("LIKE", color: .green, angle: -20)
                    Spacer()
                } else if translation.width < 0 {
                    Spacer()
                    statusLabel("NOPE", color: .red, angle: 20)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 20)
            Spacer()
        }
    }

    private var avatarOverlay: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 88, height: 88)
            .overlay(
                Image(card.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            )
            .overlay(Circle().stroke(Color.purple, lineWidth: 3))
            .shadow(radius: 3)
            .offset(y: -44)
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────────

    private var rotationAngle: Double {
        Double(translation.width / (UIScreen.main.bounds.width - 32)) * 15
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

    private func statusLabel(_ text: String, color: Color, angle: Double) -> some View {
        Text(text)
            .tracking(3)
            .font(.title2)
            .padding(.horizontal)
            .foregroundColor(color)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(color, lineWidth: 3))
            .rotationEffect(.degrees(angle))
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
