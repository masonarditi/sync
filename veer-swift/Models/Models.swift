// Models.swift

import SwiftUI

struct Entrepreneur: Identifiable {
    let id         = UUID()
    let name       : String
    let tagline    : String
    let expertise  : String
    let location   : String
    let website    : String
    let imageName  : String
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
