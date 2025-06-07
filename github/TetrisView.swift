import SwiftUI

struct BoardView: View {
    let board: [[Color?]]
    let piece: Piece

    func colorAt(row: Int, col: Int) -> Color {
        if let c = board[row][col] {
            return c
        }
        for cell in piece.tetromino.rotations[piece.rotation] {
            let px = piece.x + cell.0
            let py = piece.y + cell.1
            if px == col && py == row {
                return piece.tetromino.color
            }
        }
        return Color.black
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width / CGFloat(TetrisGame.cols), geo.size.height / CGFloat(TetrisGame.rows))
            VStack(spacing: 1) {
                ForEach(0..<TetrisGame.rows, id: \.self) { r in
                    HStack(spacing: 1) {
                        ForEach(0..<TetrisGame.cols, id: \.self) { c in
                            Rectangle()
                                .foregroundColor(colorAt(row: r, col: c))
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
        }
        .aspectRatio(CGFloat(TetrisGame.cols)/CGFloat(TetrisGame.rows), contentMode: .fit)
        .background(Color.gray.opacity(0.2))
    }
}

struct TetrisView: View {
    @StateObject private var game = TetrisGame()

    var body: some View {
        VStack {
            BoardView(board: game.board, piece: game.piece)
            HStack {
                Button("\u25C0") { game.moveLeft() }
                Button("\u25B2") { game.rotate() }
                Button("\u25B6") { game.moveRight() }
                Button("\u25BC") { game.moveDown() }
            }
            .font(.largeTitle)
            .padding()
        }
    }
}

#Preview {
    TetrisView()
}
