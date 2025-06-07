//
//  ContentView.swift
//  github
//
//  Created by Oscar Carmona on 04/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var game = TetrisGame()

    var body: some View {
        TetrisView(game: game)
    }
}

#Preview {
    ContentView()
}
