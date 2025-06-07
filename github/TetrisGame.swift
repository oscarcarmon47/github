import SwiftUI

struct Tetromino {
    let rotations: [[(Int, Int)]]
    let color: Color
}

private let tetrominoes: [Tetromino] = [
    Tetromino(
        rotations: [
            [(0,1),(1,1),(2,1),(3,1)],
            [(2,0),(2,1),(2,2),(2,3)],
            [(0,2),(1,2),(2,2),(3,2)],
            [(1,0),(1,1),(1,2),(1,3)]
        ],
        color: .cyan
    ),
    Tetromino(
        rotations: [
            [(1,0),(2,0),(1,1),(2,1)]
        ],
        color: .yellow
    ),
    Tetromino(
        rotations: [
            [(1,0),(0,1),(1,1),(2,1)],
            [(1,0),(1,1),(2,1),(1,2)],
            [(0,1),(1,1),(2,1),(1,2)],
            [(1,0),(0,1),(1,1),(1,2)]
        ],
        color: .purple
    ),
    Tetromino(
        rotations: [
            [(1,0),(2,0),(0,1),(1,1)],
            [(1,0),(1,1),(2,1),(2,2)],
            [(1,1),(2,1),(0,2),(1,2)],
            [(0,0),(0,1),(1,1),(1,2)]
        ],
        color: .green
    ),
    Tetromino(
        rotations: [
            [(0,0),(1,0),(1,1),(2,1)],
            [(2,0),(1,1),(2,1),(1,2)],
            [(0,1),(1,1),(1,2),(2,2)],
            [(1,0),(0,1),(1,1),(0,2)]
        ],
        color: .red
    ),
    Tetromino(
        rotations: [
            [(0,0),(0,1),(1,1),(2,1)],
            [(1,0),(2,0),(1,1),(1,2)],
            [(0,1),(1,1),(2,1),(2,2)],
            [(1,0),(1,1),(0,2),(1,2)]
        ],
        color: .blue
    ),
    Tetromino(
        rotations: [
            [(2,0),(0,1),(1,1),(2,1)],
            [(1,0),(1,1),(1,2),(2,2)],
            [(0,1),(1,1),(2,1),(0,2)],
            [(0,0),(1,0),(1,1),(1,2)]
        ],
        color: .orange
    )
]

struct Piece {
    var tetromino: Tetromino
    var rotation: Int = 0
    var x: Int = 3
    var y: Int = 0
}

class TetrisGame: ObservableObject {
    static let rows = 20
    static let cols = 10

    @Published var board: [[Color?]]
    @Published var piece: Piece

    private var timer: Timer?

    init() {
        board = Array(repeating: Array(repeating: nil, count: TetrisGame.cols), count: TetrisGame.rows)
        piece = Piece(tetromino: tetrominoes.randomElement()!)
        start()
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.tick()
        }
    }

    func tick() {
        if !move(dx: 0, dy: 1) {
            settlePiece()
            clearLines()
            spawn()
        }
    }

    func spawn() {
        piece = Piece(tetromino: tetrominoes.randomElement()!)
        piece.x = 3
        piece.y = 0
        if collision(x: piece.x, y: piece.y, rotation: piece.rotation) {
            board = Array(repeating: Array(repeating: nil, count: TetrisGame.cols), count: TetrisGame.rows)
        }
    }

    func rotate() {
        let newRot = (piece.rotation + 1) % piece.tetromino.rotations.count
        if !collision(x: piece.x, y: piece.y, rotation: newRot) {
            piece.rotation = newRot
        }
    }

    func moveLeft() { _ = move(dx: -1, dy: 0) }
    func moveRight() { _ = move(dx: 1, dy: 0) }
    func moveDown() { _ = move(dx: 0, dy: 1) }

    private func move(dx: Int, dy: Int) -> Bool {
        let newX = piece.x + dx
        let newY = piece.y + dy
        if !collision(x: newX, y: newY, rotation: piece.rotation) {
            piece.x = newX
            piece.y = newY
            return true
        }
        return false
    }

    private func collision(x: Int, y: Int, rotation: Int) -> Bool {
        for cell in piece.tetromino.rotations[rotation] {
            let px = x + cell.0
            let py = y + cell.1
            if px < 0 || px >= TetrisGame.cols || py >= TetrisGame.rows {
                return true
            }
            if py >= 0 && board[py][px] != nil {
                return true
            }
        }
        return false
    }

    private func settlePiece() {
        for cell in piece.tetromino.rotations[piece.rotation] {
            let px = piece.x + cell.0
            let py = piece.y + cell.1
            if py >= 0 && py < TetrisGame.rows && px >= 0 && px < TetrisGame.cols {
                board[py][px] = piece.tetromino.color
            }
        }
    }

    private func clearLines() {
        var newBoard: [[Color?]] = board.filter { row in row.contains(nil) }
        let cleared = TetrisGame.rows - newBoard.count
        if cleared > 0 {
            newBoard = Array(repeating: Array(repeating: nil, count: TetrisGame.cols), count: cleared) + newBoard
        }
        board = newBoard
    }
}
