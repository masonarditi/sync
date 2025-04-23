//
//  LoadingView.swift
//  veer-swift
//

import SwiftUI

struct LoadingView: View {
    @State private var iconRotation: Double = 0
    @State private var textScale: CGFloat = 0.01
    @State private var textOpacity: Double = 0
    @State private var animationComplete = false

    private let bgColor = Color(red: 18/255, green: 18/255, blue: 18/255)
    private let accent  = Color.purple.opacity(0.8)

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            // rotating sync icon
            Image(systemName: "arrow.2.circlepath")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(accent)
                .rotationEffect(.degrees(iconRotation))

            // app title
            Text("Sync")
                .font(.largeTitle)
                .bold()
                .foregroundColor(accent)
                .scaleEffect(textScale)
                .opacity(textOpacity)
                .offset(y: animationComplete ? 60 : 0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                iconRotation = 360
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    textScale = 1.0
                    textOpacity = 1.0
                    animationComplete = true
                }
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
            .preferredColorScheme(.dark)
    }
}
