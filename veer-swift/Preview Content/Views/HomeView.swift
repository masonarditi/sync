// HomeView.swift
import SwiftUI

// MARK: – Model
struct Entrepreneur: Identifiable {
    let id = UUID()
    let name: String
    let tagline: String
    let expertise: String
    let location: String
    let website: String
    let imageName: String
}

// Sample data – add these images to Assets.xcassets:
// “entrepreneur1”, “entrepreneur2”, “entrepreneur3”
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
    struct ActionButton {
        let id: Int
        let image: String
        let color: Color
        let height: CGFloat
    }
    private let buttons: [ActionButton] = [
        .init(id: 0, image: "arrow.counterclockwise",
              color: Color(red: 247/255, green: 181/255, blue: 50/255),
              height: 47),
        .init(id: 1, image: "xmark",
              color: Color(red: 250/255, green: 73/255, blue: 95/255),
              height: 55),
        .init(id: 2, image: "suit.heart.fill",
              color: Color(red: 60/255, green: 229/255, blue: 184/255),
              height: 55)
    ]

    // MARK: – State
    @State private var cards = [Entrepreneur]()
    @State private var forcedSwipeValues: [Int: CGFloat?] = [:]

    var body: some View {
        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .ignoresSafeArea()

            VStack {
                if cards.isEmpty {
                    emptyStateView
                } else {
                    ZStack {
                        ForEach(cards.indices, id: \.self) { idx in
                            let isTop = idx == cards.count - 1
                            CardView(
                                card: cards[idx],
                                forcedSwipe: isTop
                                    ? swipeBinding(for: idx)
                                    : .constant(nil),
                                onSwiped: {
                                    cards.remove(at: idx)
                                },
                                onMatch: { _ in /* no-op */ }
                            )
                            .shadow(radius: 5)
                        }
                    }
                }

                Spacer()

                HStack {
                    Spacer()
                    ForEach(buttons, id: \.id) { btn in
                        Button {
                            handleButtonTap(btn.id)
                        } label: {
                            Image(systemName: btn.image)
                                .font(.system(size: 23, weight: .heavy))
                                .foregroundColor(btn.color)
                                .frame(width: btn.height, height: btn.height)
                                .background(Color.white)
                                .cornerRadius(btn.height / 2)
                                .shadow(radius: 3)
                        }
                        Spacer()
                    }
                }
                .padding(.vertical, 8)
                .opacity(cards.isEmpty ? 0.5 : 1)
                .disabled(cards.isEmpty)
            }
            .onAppear { reloadCards() }
        }
    }

    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            Text("No more connections")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Check back later")
                .font(.callout)
                .foregroundColor(.gray.opacity(0.8))
            Spacer()
        }
    }

    private func handleButtonTap(_ id: Int) {
        guard !cards.isEmpty || id == 0 else { return }
        switch id {
        case 0:
            reloadCards()
        case 1:
            if let top = cards.indices.last {
                setSwipeValue(for: top, to: -500)
            }
        case 2:
            if let top = cards.indices.last {
                setSwipeValue(for: top, to: 500)
            }
        default:
            break
        }
    }

    private func setSwipeValue(for index: Int, to value: CGFloat) {
        forcedSwipeValues[index] = value
    }

    private func swipeBinding(for index: Int) -> Binding<CGFloat?> {
        Binding(
            get: { forcedSwipeValues[index] ?? nil },
            set: { forcedSwipeValues[index] = $0 }
        )
    }

    private func reloadCards() {
        cards = sampleEntrepreneurs
        forcedSwipeValues = [:]
    }
}
