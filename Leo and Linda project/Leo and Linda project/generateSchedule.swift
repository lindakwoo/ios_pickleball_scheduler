//
//  generateSchedule.swift
//  Leo and Linda project
//
//  Created by Linda Woo on 12/26/23.
//

import Foundation

public struct Team: Identifiable {
    public let id: UUID
    public let team1: (String, String)
    public let team2: (String, String)

    public init(id: UUID, team1: (String, String), team2: (String, String)) {
        self.id = id
        self.team1 = team1
        self.team2 = team2
    }
}

extension Team: CustomStringConvertible {
    public var description: String {
        return "Team 1: \(team1), Team 2: \(team2)"
    }
}


func combinations<T>(from array: [T], size: Int) -> [[T]] {
    guard array.count >= size else { return [] }
    guard size > 0 else { return [[]] }
    guard size < array.count else { return [array] }

    if size == 1 {
        return array.map { [$0] }
    }

    var result: [[T]] = []
    let restArray = Array(array.dropFirst())
    let subCombinations = combinations(from: restArray, size: size - 1)
    for combination in subCombinations {
        result.append([array[0]] + combination)
    }

    result += combinations(from: restArray, size: size)
    return result
}

public func generateSchedule(numPlayers: Int, numCourts: Int, gamesPerPlayer: Int, playerNames: [String]) -> [Team] {
    if numPlayers < 4 * numCourts {
        print("Error: not enough players")
    }
    
    var players = Array(0..<numPlayers)
    players.shuffle()
    
    var historyTracker = [[Int]](repeating: [Int](repeating: 0, count: numPlayers), count: numPlayers)
    var teamHistoryTracker = [[Int]](repeating: [Int](repeating: 0, count: numPlayers), count: numPlayers)
    var gamesCounter = [Int](repeating: 0, count: numPlayers)
    var schedule = [Team]()
    
    func hasPlayedTogether(p1: Int, p2: Int) -> Bool {
        return historyTracker[p1][p2] > 0
    }
    
    func hasBeenTeammates(p1: Int, p2: Int) -> Bool {
        return teamHistoryTracker[p1][p2] > 0
    }
    
    func validTeams(combination: [Int], attempt: Int) -> ((Int, Int), (Int, Int))? {
        let playerCombinations = combinations(from: combination, size: 2)
        for team1 in playerCombinations {
            guard let firstPlayer = team1.first, let secondPlayer = team1.last else { continue }
            
            if teamHistoryTracker[firstPlayer][secondPlayer] < attempt {
                let remainingPlayers = Set(combination).subtracting(team1)
                guard remainingPlayers.count == 2 else { continue }
                
                let team2 = Array(remainingPlayers)
                if teamHistoryTracker[team2[0]][team2[1]] < attempt {
                    // Update the history trackers for both teams
                    teamHistoryTracker[firstPlayer][secondPlayer] += 1
                    teamHistoryTracker[secondPlayer][firstPlayer] += 1
                    teamHistoryTracker[team2[0]][team2[1]] += 1
                    teamHistoryTracker[team2[1]][team2[0]] += 1
                    
                    return ((firstPlayer, secondPlayer), (team2[0], team2[1]))
                }
            }
        }
        return nil
    }
    
    let totalGames = numPlayers * gamesPerPlayer / 4
    var gamesScheduled = 0
    
    print("num players: \(numPlayers)")
    print("num courts: \(numCourts)")
    print("total games: \(totalGames)")
    
    while gamesScheduled < totalGames {
        let validCombinations = combinations(from: players, size: 4).filter {
            combination in
            return combination.allSatisfy { gamesCounter[$0] < gamesPerPlayer }
        }
        
        if validCombinations.isEmpty {
            break
        }
        
        for _ in 0..<numCourts {
            if gamesScheduled >= totalGames {
                break
            }
            
            let leastCombination = validCombinations.min { a, b in
                            a.map { gamesCounter[$0] }.reduce(0, +) < b.map { gamesCounter[$0] }.reduce(0, +)
                        } ?? []
            
            var attempt = 1
            var validTeam: ((Int, Int), (Int, Int))? = nil
            while attempt <= 3 && validTeam == nil {
                validTeam = validTeams(combination: leastCombination, attempt: attempt)
                attempt += 1
                        }

            
            if let (team1, team2) = validTeam {
                let team = Team(id: UUID(), team1: (playerNames[team1.0], playerNames[team1.1]), team2: (playerNames[team2.0], playerNames[team2.1]))
                schedule.append(team)
                
                gamesScheduled += 1
            }
            
            for combination in combinations(from: leastCombination, size: 2) {
                let p1 = combination[0]
                let p2 = combination[1]
                
                // Your existing logic here...
                historyTracker[p1][p2] += 1
                historyTracker[p2][p1] += 1
            }
            
            for p in leastCombination {
                gamesCounter[p] += 1
            }
        }
    }
    
    
print(schedule)
    return schedule
}

    
    /*func combinations<T>(arr: [T], combinationSize: Int) -> [[T]] {
        var combinations = [[T]]()
        
        // Generate combinations iteratively
        for i in 0 ..< (1 << arr.count) {
            if i.nonzeroBitCount == combinationSize {
                var combination = [T]()
                for j in 0 ..< arr.count {
                    if (i & (1 << j)) != 0 {
                        combination.append(arr[j])
                    }
                }
                combinations.append(combination)
            }
        }
        
        return combinations
    }*/
