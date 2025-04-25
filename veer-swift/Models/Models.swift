// Models.swift
import SwiftUI

struct Entrepreneur: Identifiable {
    let id          = UUID()
    let name        : String
    let tagline     : String
    let company     : String
    let bio         : String
    let expertise   : String
    let location    : String
    let lookingFor  : [String]   // now an array for multiple bubbles
    let funding     : String     // e.g. "Series A", "$2M Seed"
    let matchScore  : Int        // 1–10
    let imageName   : String
}

let sampleEntrepreneurs: [Entrepreneur] = [
    .init(
        name:       "Alice Johnson",
        tagline:    "Early-stage startup founder",
        company:    "Alpha AI Labs",
        bio:        "We build cutting-edge AI solutions for social good.",
        expertise:  "AI · Blockchain",
        location:   "San Francisco, CA",
        lookingFor: ["Technical co-founders", "Seed funding"],
        funding:    "Seed: $500K",
        matchScore: 7,
        imageName:  "entrepreneur1"
    ),
    .init(
        name:       "Bob Patel",
        tagline:    "Creative director & UX expert",
        company:    "BrandCraft Studio",
        bio:        "Designing user-centric brand experiences for startups.",
        expertise:  "Design · Branding",
        location:   "New York, NY",
        lookingFor: ["Mentors", "Design collaborators"],
        funding:    "Bootstrapped",
        matchScore: 5,
        imageName:  "entrepreneur2"
    ),
    .init(
        name:       "Carla Ruiz",
        tagline:    "Series A ed-tech CEO",
        company:    "Edify Inc.",
        bio:        "Scaling personalized education platforms worldwide.",
        expertise:  "Education · Product",
        location:   "Austin, TX",
        lookingFor: ["Product managers", "Ed-tech partners"],
        funding:    "Series A: $5M",
        matchScore: 9,
        imageName:  "entrepreneur3"
    )
]
