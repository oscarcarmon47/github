import SwiftUI

/// Model object holding the state of a simple Tetris game.
final class TetrisGame: ObservableObject {
    static let rows = 20
    static let columns = 10

    /// Board stores fixed blocks. `nil` means the cell is empty.
    @Published var board: [[Color?]]
    /// Current score based on cleared lines.
    @Published var score: Int = 0

    private var timer: Timer?

    /// Description for a tetromino piece.
    private struct Tetromino {
        /// Array of rotations. Each rotation is an array of row/column offsets.
        let rotations: [[(Int, Int)]]
        let color: Color
    }

    private var current: Tetromino?
    private var rotationIndex: Int = 0
    private var position: (row: Int, col: Int) = (0, 3)

    init() {
        board = Array(
            repeating: Array(repeating: nil, count: Self.columns),
            count: Self.rows
        )
        spawnPiece()
        startTimer()
    }

    // MARK: - Public API

    /// Move the current piece one cell down. If the piece cannot move it
    /// becomes part of the board and a new piece is spawned.
    func drop() {
        if !collision(row: position.row + 1, col: position.col, rotation: rotationIndex) {
            position.row += 1
        } else {
            lockPiece()
            clearLines()
            spawnPiece()
        }
    }

    /// Move the current piece left if possible.
    func moveLeft() {
        if !collision(row: position.row, col: position.col - 1, rotation: rotationIndex) {
            position.col -= 1
        }
    }

    /// Move the current piece right if possible.
    func moveRight() {
        if !collision(row: position.row, col: position.col + 1, rotation: rotationIndex) {
            position.col += 1
        }
    }

    /// Rotate the current piece if it fits in the board.
    func rotate() {
        let next = rotationIndex + 1
        if !collision(row: position.row, col: position.col, rotation: next) {
            rotationIndex = next
        }
    }

    /// Drop the piece to the bottom instantly.
    func hardDrop() {
        while !collision(row: position.row + 1, col: position.col, rotation: rotationIndex) {
            position.row += 1
        }
        drop()
    }

    /// Returns the blocks of the current active piece translated to board
    /// coordinates.
    func activeBlocks() -> [Block] {
        guard let current else { return [] }
        let active = blocks(row: position.row, col: position.col, rotation: rotationIndex)
        return active.map { Block(row: $0.0, column: $0.1, color: current.color) }
    }

    // MARK: - Internal helpers

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.drop()
        }
    }

    private func spawnPiece() {
        current = Self.tetrominoes.randomElement()
        rotationIndex = 0
        position = (0, 3)
        // Game over detection: reset board and score
        if collision(row: position.row, col: position.col, rotation: rotationIndex) {
            board = Array(
                repeating: Array(repeating: nil, count: Self.columns),
                count: Self.rows
            )
            score = 0
        }
    }

    private func blocks(row: Int, col: Int, rotation: Int) -> [(Int, Int)] {
        guard let current else { return [] }
        let shape = current.rotations[rotation % current.rotations.count]
        return shape.map { (r, c) in (r + row, c + col) }
    }

    private func collision(row: Int, col: Int, rotation: Int) -> Bool {
        for (r, c) in blocks(row: row, col: col, rotation: rotation) {
            if r < 0 || r >= Self.rows || c < 0 || c >= Self.columns { return true }
            if board[r][c] != nil { return true }
        }
        return false
    }

    private func lockPiece() {
        guard let current else { return }
        for (r, c) in blocks(row: position.row, col: position.col, rotation: rotationIndex) {
            if r >= 0 && r < Self.rows && c >= 0 && c < Self.columns {
                board[r][c] = current.color
            }
        }
    }

    private func clearLines() {
        var newBoard: [[Color?]] = []
        for row in board {
            if row.allSatisfy({ $0 != nil }) {
                score += 100
            } else {
                newBoard.append(row)
            }
        }
        while newBoard.count < Self.rows {
            newBoard.insert(Array(repeating: nil, count: Self.columns), at: 0)
        }
        board = newBoard
    }

    // MARK: - Tetromino definitions

    /// Single block used when rendering the board or active piece.
    struct Block: Identifiable {
        let id = UUID()
        let row: Int
        let column: Int
        let color: Color
    }

    /// Basic set of Tetris pieces.
    private static let tetrominoes: [Tetromino] = [
        // I
        Tetromino(
            rotations: [
                [(0,0),(0,1),(0,2),(0,3)],
                [(-1,1),(0,1),(1,1),(2,1)]
            ],
            color: .cyan
        ),
        // O
        Tetromino(
            rotations: [
                [(0,0),(0,1),(1,0),(1,1)]
            ],
            color: .yellow
        ),
        // T
        Tetromino(
            rotations: [
                [(0,1),(1,0),(1,1),(1,2)],
                [(0,1),(1,1),(1,2),(2,1)],
                [(1,0),(1,1),(1,2),(2,1)],
                [(0,1),(1,0),(1,1),(2,1)]
            ],
            color: .purple
        ),
        // L
        Tetromino(
            rotations: [
                [(0,2),(1,0),(1,1),(1,2)],
                [(0,1),(0,2),(1,1),(2,1)],
                [(1,0),(1,1),(1,2),(2,0)],
                [(0,1),(1,1),(2,1),(2,2)]
            ],
            color: .orange
        ),
        // J
        Tetromino(
            rotations: [
                [(0,0),(1,0),(1,1),(1,2)],
                [(0,1),(0,2),(1,1),(2,1)],
                [(1,0),(1,1),(1,2),(2,2)],
                [(0,1),(1,1),(2,0),(2,1)]
            ],
            color: .blue
        ),
        // S
        Tetromino(
            rotations: [
                [(0,1),(0,2),(1,0),(1,1)],
                [(0,0),(1,0),(1,1),(2,1)]
            ],
            color: .green
        ),
        // Z
        Tetromino(
            rotations: [
                [(0,0),(0,1),(1,1),(1,2)],
                [(0,1),(1,0),(1,1),(2,0)]
            ],
            color: .red
        )
    ]
}


