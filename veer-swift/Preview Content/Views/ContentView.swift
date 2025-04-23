//
//  ContentView.swift
//  veer-swift
//

import SwiftUI

// MARK: — Tab definition
struct TabItem: Identifiable {
    let id: Int
    let image: String
}

fileprivate let tabs: [TabItem] = [
    .init(id: 0, image: "flame.fill"),
    .init(id: 1, image: "sparkles"),
    .init(id: 2, image: "message.fill"),
    .init(id: 3, image: "person.fill")
]

// MARK: — ContentView
struct ContentView: View {
    @State private var selectedTab = 0

    private let bgColor = Color(red: 18/255, green: 18/255, blue: 18/255)
    private let accent  = Color.purple

    var body: some View {
        VStack(spacing: 0) {
            // Main Content
            TabView(selection: $selectedTab) {
                HomeView()     .tag(0)
                LikesView()    .tag(1)
                MessagesView() .tag(2)
                ProfileView()  .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .background(bgColor)

            // Bottom Tab Bar
            Divider().background(Color.white.opacity(0.2))
            HStack {
                ForEach(tabs) { tab in
                    Spacer()
                    Image(systemName: tab.image)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(tab.id == selectedTab
                                         ? accent
                                         : Color.white.opacity(0.6))
                        .onTapGesture {
                            withAnimation { selectedTab = tab.id }
                        }
                    Spacer()
                }
            }
            .padding(.vertical, 12)
            .background(bgColor)
        }
        .background(bgColor.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

// MARK: — Placeholder Subviews
struct HomeView: View {
    var body: some View {
        ZStack { Color(red: 28/255, green: 28/255, blue: 28/255).ignoresSafeArea()
            Text("Home")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}
struct LikesView: View {
    var body: some View {
        ZStack { Color(red: 28/255, green: 28/255, blue: 28/255).ignoresSafeArea()
            Text("Likes")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}
struct MessagesView: View {
    var body: some View {
        ZStack { Color(red: 28/255, green: 28/255, blue: 28/255).ignoresSafeArea()
            Text("Messages")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}
struct ProfileView: View {
    var body: some View {
        ZStack { Color(red: 28/255, green: 28/255, blue: 28/255).ignoresSafeArea()
            Text("Profile")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

// MARK: — Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
