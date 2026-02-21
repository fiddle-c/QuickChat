//
//  ContentView.swift
//  QuickChat
//
//  Created by Karlos Flor on 2/9/26.
//

import SwiftUI

struct RootView: View {
    @State private var isAuthenticated: Bool = false
    var body: some View {
        ZStack {
            if isAuthenticated {
                HomeView(agent: Agent())
            } else {
                LoginView()
            }
            
        }

    }
}

#Preview {
    RootView()
}
