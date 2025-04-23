// CardView.swift
import SwiftUI

struct CardView: View {
    var card: Entrepreneur
    @Binding var forcedSwipe: CGFloat?
    var onSwiped: () -> Void
    var onMatch: (String) -> Void

    @State private var translation: CGSize = .zero
    @State private var page = 1

    var body: some View {
        ZStack {
            // Image fills the parent frame
            Image(card.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.7), .clear]),
                        startPoint: .bottom,
                        endPoint: .center
                    )
                )

            // LIKE/NOPE overlays
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
                .padding(.top, 40)
                .padding(.horizontal, 25)
                Spacer()
            }

            // Paging overlays
            Group {
                if page == 1   { pageOne() }
                else if page == 2 { pageTwo() }
                else            { pageThree() }
            }
        }
        .cornerRadius(15)
        .shadow(radius: 5)
        .offset(x: translation.width)
        .rotationEffect(
            .degrees(Double(translation.width / (UIScreen.main.bounds.width - 32)) * 25),
            anchor: .bottom
        )
        .gesture(dragGesture())
        .onTapGesture { page = page % 3 + 1 }
        .onChange(of: forcedSwipe) { val in
            guard let x = val else { return }
            withAnimation(.easeInOut) { translation.width = x }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                onSwiped()
                translation = .zero
            }
        }
    }

    // MARK: — Drag gesture
    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { translation = $0.translation }
            .onEnded { _ in
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
    }

    private func scheduleRemoval() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onSwiped()
            translation = .zero
        }
    }

    // MARK: — Status label
    private func statusLabel(_ text: String, color: Color, angle: Double) -> some View {
        Text(text)
            .tracking(3)
            .font(.title)
            .padding(.horizontal)
            .foregroundColor(color)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(color, lineWidth: 3))
            .rotationEffect(.degrees(angle))
    }

    // MARK: — Page overlays
    private func pageOne() -> some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(card.name)
                .font(.largeTitle).bold().foregroundColor(.white)
            Text(card.tagline)
                .font(.title2).foregroundColor(.white.opacity(0.9))
            Spacer().frame(height: 48)
        }
        .padding(16)
    }

    private func pageTwo() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 Expertise:")
                .font(.headline).foregroundColor(.white)
            Text(card.expertise)
                .font(.title2).foregroundColor(.white)
            Text("📍 \(card.location)")
                .font(.subheadline).foregroundColor(.white.opacity(0.8))
            Spacer()
        }
        .padding(16)
    }

    private func pageThree() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔗 Website:")
                .font(.headline).foregroundColor(.white)
            Text(card.website)
                .font(.title3).foregroundColor(.blue)
            Spacer()
        }
        .padding(16)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(
            card: sampleEntrepreneurs.first!,
            forcedSwipe: .constant(nil),
            onSwiped: {},
            onMatch: { _ in }
        )
        .frame(width: UIScreen.main.bounds.width - 32, height: 450)
        .preferredColorScheme(.dark)
    }
}
