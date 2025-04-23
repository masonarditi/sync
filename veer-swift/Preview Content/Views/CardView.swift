// CardView.swift
import SwiftUI

struct CardView: View {
    var card: Entrepreneur

    // drag state
    @State private var translation: CGSize = .zero

    // parent-forced swipe
    @Binding var forcedSwipe: CGFloat?

    // callbacks
    var onSwiped: () -> Void
    var onMatch: (String) -> Void

    // which page to show
    @State private var currentPage = 1

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background image + vignette
                Image(card.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width - 32)
                    .clipped()
                    .cornerRadius(15)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.7),
                                Color.clear
                            ]),
                            startPoint: .bottom,
                            endPoint: .center
                        )
                        .cornerRadius(15)
                    )

                // LIKE / NOPE overlays
                VStack {
                    HStack {
                        if translation.width > 0 {
                            label("LIKE", color: .green, angle: -20)
                            Spacer()
                        } else if translation.width < 0 {
                            Spacer()
                            label("NOPE", color: .red, angle: 20)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 40)
                    Spacer()
                }

                // Page overlays
                Group {
                    if currentPage == 1 {
                        pageOneOverlay()
                    } else if currentPage == 2 {
                        pageTwoOverlay()
                    } else {
                        pageThreeOverlay()
                    }
                }
            }
            .offset(x: translation.width)
            .rotationEffect(.degrees(Double(translation.width / geo.size.width) * 25),
                            anchor: .bottom)
            .gesture(dragGesture())
            .onTapGesture { cyclePage() }
            .onChange(of: forcedSwipe) { val in
                guard let x = val else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    translation.width = x
                }
                removeAfterDelay(0.4)
            }
        }
        .padding(16)
    }

    // MARK: – Gestures & Helpers

    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { translation = $0.translation }
            .onEnded { _ in
                withAnimation(.easeInOut) {
                    if translation.width > 150 {
                        translation.width = 500
                        onMatch(card.name)
                        removeAfterDelay(0.4)
                    } else if translation.width < -150 {
                        translation.width = -500
                        onSwiped()
                        removeAfterDelay(0.4)
                    } else {
                        translation = .zero
                    }
                }
            }
    }

    private func removeAfterDelay(_ delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            onSwiped()
            translation = .zero
        }
    }

    private func cyclePage() {
        currentPage = currentPage % 3 + 1
    }

    private func label(_ text: String, color: Color, angle: Double) -> some View {
        Text(text)
            .tracking(3)
            .font(.title)
            .padding(.horizontal)
            .foregroundColor(color)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(color, lineWidth: 3)
            )
            .rotationEffect(.degrees(angle))
    }

    // MARK: – Page Overlays

    private func pageOneOverlay() -> some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(card.name)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.white)
            Text(card.tagline)
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
            Spacer().frame(height: 48)
        }
        .padding(16)
    }

    private func pageTwoOverlay() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 Expertise:")
                .font(.headline)
                .foregroundColor(.white)
            Text(card.expertise)
                .font(.title2)
                .foregroundColor(.white)
            Text("📍 \(card.location)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
        }
        .padding(16)
    }

    private func pageThreeOverlay() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔗 Website:")
                .font(.headline)
                .foregroundColor(.white)
            Text(card.website)
                .font(.title3)
                .foregroundColor(.blue)
            Spacer()
        }
        .padding(16)
    }
}
