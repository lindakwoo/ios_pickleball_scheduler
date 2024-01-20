//
//  generateSchedule.swift
//  Leo and Linda project
//
//  Created by Linda Woo on 12/26/23.
//
import Foundation

struct Game: Identifiable {
    let id: UUID
    let team1: [String]
    let team2: [String]

    var description: String {
        "\(team1.joined(separator: " / ")) vs. \(team2.joined(separator: " / "))"
    }

    init(team1: [String], team2: [String]) {
        self.id = UUID()
        self.team1 = team1
        self.team2 = team2
    }
}

struct Round: Identifiable {
    let id = UUID()
    let roundNumber: Int
    let games: [Game]

    // Generate a description for each game with its number
    func gameDescriptions() -> [String] {
        return games.enumerated().map { (index, game) in
            "Game \(index + 1): \(game.description)"
        }
    }
}

func generateSchedule(numPlayers: Int, numCourts: Int, playerNames: [String]) -> [[Game]] {
    guard playerNames.count >= numPlayers, numPlayers >= 4 else {
        print("Error: Not enough players or player names provided.")
        return []
    }
    var gamesPerPlayer = numPlayers-1
    var schedule = [[Game]]()
    var gamesCounter = [Int](repeating: 0, count: numPlayers)
    var teamHistory = Set<Set<Int>>()  // Track teams by player indices
    var playerIndices = Array(0..<numPlayers)  // Work with player indices
    let finished = false
    let maxGamesPlayed = min(gamesPerPlayer, numPlayers-1)

    while gamesCounter.min() ?? 0 < maxGamesPlayed {
        var roundGames = [Game]()
        var usedPlayers = Set<Int>()
        playerIndices.shuffle()  // Shuffle indices, not names

        // Sort player indices by the number of games played
        let priorityPlayers = playerIndices.sorted { gamesCounter[$0] < gamesCounter[$1] }
        // number of games per round can't exceed the minimum of either the number of courts available or the number of players divided by 4
        let maxGamesPerRound = min(numCourts, Int(floor(Double(numPlayers) / 4.0)))
    


        for combo in combinations(from: priorityPlayers, size: 4) {
            guard combo.count == 4 else { continue }

            for teamIndexes in combinations(from: combo, size: 2) {
                guard teamIndexes.count == 2 else { continue }
                let remainingIndexes = Set(combo).subtracting(teamIndexes)
                guard remainingIndexes.count == 2 else { continue }

                let team1 = Set(teamIndexes)
                let team2 = remainingIndexes

                // Ensure unique teams and that players aren't already used this round
                if !teamHistory.contains(team1) && !teamHistory.contains(team2) &&
                   usedPlayers.isDisjoint(with: team1) && usedPlayers.isDisjoint(with: team2) {
                    
                    // Create a new Game with player names, not indices
                    let newGame = Game(team1: team1.map { playerNames[$0] },
                                       team2: team2.map { playerNames[$0] })
                    roundGames.append(newGame)

                    // Update histories and counters
                    teamHistory.insert(team1)
                    teamHistory.insert(team2)
                    usedPlayers.formUnion(team1)
                    usedPlayers.formUnion(team2)
                    team1.forEach { gamesCounter[$0] += 1 }
                    team2.forEach { gamesCounter[$0] += 1 }
                    
                    if roundGames.count >= maxGamesPerRound {
                        break
                    }
                }
            }
            if roundGames.count >= maxGamesPerRound {
                break
            }
        }

     if roundGames.count >= maxGamesPerRound {
        schedule.append(roundGames)
    } else {
    
        // If the round does not satisfy the conditions, reset team history so it can repeat a team to finish the round
        teamHistory.removeAll()
    }

  
    }
    
    return schedule
}


func combinations<T>(from array: [T], size: Int) -> [[T]] {
    var res = [[T]]()
    var temp = [T]()

    func backtracking(start: Int) {
        if temp.count == size {
            res.append(temp)
            return
        }

        for i in start..<array.count {
            temp.append(array[i])
            backtracking(start: i + 1)
            temp.removeLast()
        }
    }

    backtracking(start: 0)
    return res
}
