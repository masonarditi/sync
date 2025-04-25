import SwiftUI

struct CardView: View {
    var card: Entrepreneur
    @Binding var forcedSwipe: CGFloat?
    var onSwiped: () -> Void
    var onMatch: (String) -> Void

    @State private var translation: CGSize = .zero

    var body: some View {
        ZStack {
            // ─── background ────────────────────
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(white: 0.97))
                .shadow(radius: 5)

            // ─── content ────────────────────────
            VStack(spacing: 12) {
                // room for avatar
                Spacer().frame(height: 44)

                Text(card.name)
                  .font(.title2).bold()
                  .foregroundColor(.black)
                  .multilineTextAlignment(.center)

                Text(card.tagline)
                  .font(.subheadline)
                  .foregroundColor(.gray)
                  .multilineTextAlignment(.center)

                // NEW: company & bio
                Text(card.company)
                  .font(.body).bold()
                  .foregroundColor(.black)
                  .multilineTextAlignment(.center)

                Text(card.bio)
                  .font(.caption)
                  .foregroundColor(.gray)
                  .multilineTextAlignment(.center)

                // expertise tags
                HStack(spacing: 8) {
                    ForEach(card.expertise.components(separatedBy: " · "), id: \.self) { tag in
                        Text(tag)
                          .font(.caption2)
                          .padding(.horizontal, 10)
                          .padding(.vertical, 4)
                          .background(Color.purple.opacity(0.2))
                          .foregroundColor(.purple)
                          .clipShape(Capsule())
                    }
                }

                // “Looking for” pill
                Text("Looking for: \(card.lookingFor)")
                  .font(.caption)
                  .foregroundColor(.white)
                  .padding(.vertical, 8)
                  .padding(.horizontal, 12)
                  .background(Color.purple)
                  .cornerRadius(10)

                // **no** bottom Spacer() → content hugs bottom
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            // ─── like / nope overlay ───────────
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
        .frame(
          width: UIScreen.main.bounds.width - 32,
          height: 540
        )
        // ─── avatar overlay ────────────────
        .overlay(
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
              .offset(y: -44),
            alignment: .top
        )
        // ─── swipe transforms ───────────────
        .offset(x: translation.width)
        .rotationEffect(
          .degrees(Double(translation.width / (UIScreen.main.bounds.width - 32)) * 15),
          anchor: .bottom
        )
        .gesture(dragGesture())
        .onChange(of: forcedSwipe) { val in
            guard let x = val else { return }
            withAnimation(.easeInOut) { translation.width = x }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwiped(); translation = .zero
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
                translation.width = 600; onMatch(card.name); scheduleRemoval()
              } else if translation.width < -150 {
                translation.width = -600; onSwiped(); scheduleRemoval()
              } else {
                translation = .zero
              }
            }
          }
    }

    private func scheduleRemoval() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          onSwiped(); translation = .zero
        }
    }

    // MARK: — LIKE/NOPE label
    private func statusLabel(_ text: String, color: Color, angle: Double) -> some View {
        Text(text)
          .tracking(3)
          .font(.title2)
          .padding(.horizontal)
          .foregroundColor(color)
          .overlay(
            RoundedRectangle(cornerRadius: 5)
              .stroke(color, lineWidth: 3)
          )
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
