import SwiftUI

struct TetrisView: View {
    let game: TetrisGame

    var body: some View {
        Text("Score: \(game.score)")
    }
}

#Preview {
    TetrisView(game: TetrisGame())
}
