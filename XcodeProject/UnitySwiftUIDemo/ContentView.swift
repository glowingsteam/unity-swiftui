//
//  ContentView.swift
//  UnitySwiftUIDemo
//
//  Created by Benjamin Dewey on 12/24/23.
//

import SwiftUI

struct ContentView: View {
    @State private var playerSize = 0
    @State private var loading = false
    @State private var miniplayerSquare = true
    @State private var UnityContainer: UIViewContainer?
    @State private var miniplayerAlignment = Alignment.top

    var body: some View {
        if let UnityContainer = UnityContainer {
            GeometryReader(content: { geometry in
                ZStack(content: {
                    ZStack(alignment: miniplayerAlignment, content: {
                        Color.clear
                        UnityContainer.if(playerSize == 0, transform: {
                            $0.ignoresSafeArea()
                        }).if(playerSize == 2 && miniplayerSquare, transform: {
                            $0.frame(width: 200, height: 200)
                        }).if(playerSize == 2 && !miniplayerSquare, transform: {
                            $0.frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)
                        })
                    })
                    VStack(content: {
                        Picker("Player size", selection: $playerSize, content: {
                            Text("Fullscreen").tag(0)
                            Text("Safe area").tag(1)
                            Text("Miniplayer").tag(2)
                        }).pickerStyle(.segmented)
                        if playerSize == 2 {
                            Picker("Miniplayer alignment", selection: $miniplayerAlignment, content: {
                                Text("Top").tag(Alignment.top)
                                Text("Center").tag(Alignment.center)
                                Text("Bottom").tag(Alignment.bottom)
                            }).pickerStyle(.segmented)
                            Picker("Miniplayer shape", selection: $miniplayerSquare, content: {
                                Text("Square").tag(true)
                                Text("Aspect").tag(false)
                            }).pickerStyle(.segmented)
                        }
                    }).padding()
                })
            })
        } else {
            if loading {
                ProgressView("Loading...")
            } else {
                Button("Start Unity", action: {
                    /* Create a container view for Unity. This must be done on
                     the main thread which will be blocked while Unity starts. Use
                     async so we can render a ProgressView before the thread blocks. */
                    loading = true
                    DispatchQueue.main.async(execute: {
                        UnityContainer = UIViewContainer(containee: Unity.shared.view)
                        loading = false
                    })
                }).buttonStyle(.borderedProminent)
            }
        }
    }
}

extension Alignment: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .top: hasher.combine(0)
        case .center: hasher.combine(1)
        case .bottom: hasher.combine(2)
        default: hasher.combine(3) // Handle custom alignments if needed
        }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    ContentView()
}
