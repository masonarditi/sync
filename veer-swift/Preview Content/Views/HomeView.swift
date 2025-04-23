// HomeView.swift
import SwiftUI

// MARK: – Model & Sample Data
struct Entrepreneur: Identifiable {
    let id = UUID()
    let name: String
    let tagline: String
    let expertise: String
    let location: String
    let website: String
    let imageName: String
}

let sampleEntrepreneurs: [Entrepreneur] = [
    .init(name: "Alice Johnson",
          tagline: "Early-stage startup founder",
          expertise: "AI · Blockchain",
          location: "San Francisco, CA",
          website: "alice.io",
          imageName: "entrepreneur1"),
    .init(name: "Bob Patel",
          tagline: "Creative director & UX expert",
          expertise: "Design · Branding",
          location: "New York, NY",
          website: "bobpatel.design",
          imageName: "entrepreneur2"),
    .init(name: "Carla Ruiz",
          tagline: "Series A ed-tech CEO",
          expertise: "Education · Product",
          location: "Austin, TX",
          website: "carlaed.tech",
          imageName: "entrepreneur3")
]

struct HomeView: View {
    // MARK: – Action Buttons
    struct ActionButton: Identifiable {
        let id: Int
        let systemImage: String
        let color: Color
    }
    private let buttons: [ActionButton] = [
        .init(id: 0, systemImage: "arrow.counterclockwise", color: .yellow),
        .init(id: 1, systemImage: "xmark",                 color: .red),
        .init(id: 2, systemImage: "suit.heart.fill",       color: .green)
    ]

    // MARK: – State
    @State private var cards = sampleEntrepreneurs
    @State private var forcedSwipeValues: [UUID: CGFloat?] = [:]

    var body: some View {
        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // ─── Card Stack ──────────────────────────
                ZStack {
                    ForEach(cards) { card in
                        let isTop = card.id == cards.last?.id
                        CardView(
                            card: card,
                            forcedSwipe: isTop
                                ? swipeBinding(for: card.id)
                                : .constant(nil),
                            onSwiped: { remove(card) },
                            onMatch:   { _ in }
                        )
                        .frame(
                            width: UIScreen.main.bounds.width - 32,
                            height: 450
                        )
                        .shadow(radius: 5)
                    }
                }
                .frame(
                    width: UIScreen.main.bounds.width - 32,
                    height: 450
                )

                Spacer()

                // ─── Action Buttons ──────────────────────
                HStack(spacing: 60) {
                    ForEach(buttons) { btn in
                        Button {
                            handleButtonTap(btn.id)
                        } label: {
                            Image(systemName: btn.systemImage)
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundColor(btn.color)
                                .frame(width: 64, height: 64)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                    }
                }
                .padding(.bottom, 40)
                .opacity(cards.isEmpty ? 0.5 : 1)
                .disabled(cards.isEmpty)
            }
        }
    }

    // MARK: – Helpers

    private func handleButtonTap(_ id: Int) {
        guard !cards.isEmpty || id == 0 else { return }
        switch id {
        case 0:
            reloadCards()
        case 1:
            if let top = cards.last {
                forcedSwipeValues[top.id] = -500
            }
        case 2:
            if let top = cards.last {
                forcedSwipeValues[top.id] = 500
            }
        default: break
        }
    }

    private func swipeBinding(for id: UUID) -> Binding<CGFloat?> {
        Binding(
            get: { forcedSwipeValues[id] ?? nil },
            set: { forcedSwipeValues[id] = $0 }
        )
    }

    private func remove(_ card: Entrepreneur) {
        withAnimation {
            cards.removeAll { $0.id == card.id }
            forcedSwipeValues[card.id] = nil
        }
    }

    private func reloadCards() {
        cards = sampleEntrepreneurs
        forcedSwipeValues = [:]
    }
}
