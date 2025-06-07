import SwiftUI

/// Visual representation for the Tetris board and controls.
struct TetrisView: View {
    @ObservedObject var game: TetrisGame

    var body: some View {
        VStack {
            Text("Score: \(game.score)")
                .font(.headline)
            board
            controls
        }
        .padding()
    }

    private var board: some View {
        GeometryReader { geo in
            let cellSize = geo.size.width / CGFloat(TetrisGame.columns)
            VStack(spacing: 1) {
                ForEach(0..<TetrisGame.rows, id: \.self) { r in
                    HStack(spacing: 1) {
                        ForEach(0..<TetrisGame.columns, id: \.self) { c in
                            Rectangle()
                                .foregroundColor(colorAt(row: r, col: c))
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
        .aspectRatio(CGFloat(TetrisGame.columns)/CGFloat(TetrisGame.rows), contentMode: .fit)
        .background(Color.gray.opacity(0.2))
        .padding(8)
    }

    private func colorAt(row: Int, col: Int) -> Color {
        if let color = game.board[row][col] {
            return color
        }
        if let block = game.activeBlocks().first(where: { $0.row == row && $0.column == col }) {
            return block.color
        }
        return Color.black.opacity(0.1)
    }

    private var controls: some View {
        HStack(spacing: 40) {
            Button("◀︎") { game.moveLeft() }
            Button("▲") { game.rotate() }
            Button("▶︎") { game.moveRight() }
            Button("▼") { game.drop() }
        }
        .font(.largeTitle)
        .padding(.top)
    }
}

#Preview {
    TetrisView(game: TetrisGame())
}
