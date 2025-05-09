// HomeView.swift
import SwiftUI

struct HomeView: View {
    struct ActionButton: Identifiable {
        let id: Int
        let icon: String
        let color: Color
    }

    private let buttons = [
        ActionButton(id: 0, icon: "arrow.counterclockwise", color: .yellow),
        ActionButton(id: 1, icon: "xmark",                 color: .red),
        ActionButton(id: 2, icon: "suit.heart.fill",       color: .green)
    ]

    @State private var cards = sampleEntrepreneurs
    @State private var forcedSwipe: [UUID: CGFloat?] = [:]

    var body: some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()

            VStack {
                Spacer(minLength: 110)

                // ─── card stack ────────────────────────────
                ZStack {
                    ForEach(cards) { card in
                        let isTop = card.id == cards.last?.id
                        CardView(
                            card: card,
                            forcedSwipe: isTop
                                ? Binding(
                                    get: { forcedSwipe[card.id] ?? nil },
                                    set: { forcedSwipe[card.id] = $0 }
                                  )
                                : .constant(nil),
                            onSwiped: { remove(card) },
                            onMatch:  { _ in }
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

                // ─── buttons ────────────────────────────────
                HStack(spacing: 50) {
                    ForEach(buttons) { btn in
                        Button {
                            tap(btn.id)
                        } label: {
                            Image(systemName: btn.icon)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(btn.color)
                                .frame(width: 50, height: 50)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        // Only disable “discard” and “like” when empty
                        .disabled(btn.id != 0 && cards.isEmpty)
                        .opacity(btn.id != 0 && cards.isEmpty ? 0.5 : 1)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func tap(_ id: Int) {
        switch id {
        case 0:
            // restart
            withAnimation {
                cards = sampleEntrepreneurs
                forcedSwipe = [:]
            }

        case 1:
            // swipe left
            if let top = cards.last {
                forcedSwipe[top.id] = -500
            }

        case 2:
            // swipe right
            if let top = cards.last {
                forcedSwipe[top.id] = 500
            }

        default:
            break
        }
    }

    private func remove(_ card: Entrepreneur) {
        withAnimation {
            cards.removeAll { $0.id == card.id }
        }
    }
}
