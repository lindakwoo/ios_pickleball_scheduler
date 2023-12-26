//
//  generateSchedule.swift
//  Pickleball Game Scheduler
//
//  Created by Linda Woo on 12/26/23.
//

import Foundation

public func generateSchedule(numPlayers: Int, numCourts: Int, gamesPerPlayer: Int) -> String {
    if numPlayers < 4 * numCourts {
        return "Error: not enough players"
    }
    
    var players = Array(0..<numPlayers)
    players.shuffle()
    
    var historyTracker = [[Int]](repeating: [Int](repeating: 0, count: numPlayers), count: numPlayers)
    var teamHistoryTracker = [[Int]](repeating: [Int](repeating: 0, count: numPlayers), count: numPlayers)
    var gamesCounter = [Int](repeating: 0, count: numPlayers)
    var schedule = [(team1: (Int, Int), team2: (Int, Int))]()
    
    func hasPlayedTogether(p1: Int, p2: Int) -> Bool {
        return historyTracker[p1][p2] > 0
    }
    
    func hasBeenTeammates(p1: Int, p2: Int) -> Bool {
        return teamHistoryTracker[p1][p2] > 0
    }
    
    func validTeams(combination: [Int]) -> ((Int, Int), (Int, Int))? {
        for team in combinations(elements: combination, k: 2) {
            if !hasBeenTeammates(p1: team.0, p2: team.1) {
                let remainingPlayers = Set(combination).subtracting([team.0, team.1])
                let remainingArray = Array(remainingPlayers)
                let otherTeam = (remainingArray[0], remainingArray[1])
                
                if !hasBeenTeammates(p1: otherTeam.0, p2: otherTeam.1) {
                    teamHistoryTracker[team.0][team.1] += 1
                    teamHistoryTracker[team.1][team.0] += 1
                    
                    teamHistoryTracker[otherTeam.0][otherTeam.1] += 1
                    teamHistoryTracker[otherTeam.1][otherTeam.0] += 1
                    
                    return (team, otherTeam)
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
        let validCombinations = combinations(elements: players, k: 4).filter {
            combination in
            return gamesCounter[combination.0] < gamesPerPlayer && gamesCounter[combination.1] < gamesPerPlayer
        }
        
        if validCombinations.isEmpty {
            break
        }
        
        for _ in 0..<numCourts {
            if gamesScheduled >= totalGames {
                break
            }
            
            let leastCombination = validCombinations.min { team1, team2 in
                let sum1 = gamesCounter[team1.0] + gamesCounter[team1.1]
                let sum2 = gamesCounter[team2.0] + gamesCounter[team2.1]
                return sum1 < sum2
            }
            
            if let leastCombinationTuple = leastCombination,
               let leastCombination = validTeams(combination: [leastCombinationTuple.0, leastCombinationTuple.1]) {
                let (team1, team2) = leastCombination
                schedule.append((team1: team1, team2: team2))
                gamesScheduled += 1
                
                for (p1, p2) in combinations(elements: [leastCombinationTuple.0, leastCombinationTuple.1], k: 2) {
                    historyTracker[p1][p2] += 1
                    historyTracker[p2][p1] += 1
                }
                
                for p in [leastCombinationTuple.0, leastCombinationTuple.1] {
                    gamesCounter[p] += 1
                }
            }
        }
    }
    
    return "\(schedule)"
}

// Helper function to generate combinations of elements
func combinations<T>(elements: [T], k: Int) -> [(T, T)] {
    var result = [(T, T)]()
    for i in 0..<elements.count {
        for j in i+1..<elements.count {
            result.append((elements[i], elements[j]))
        }
    }
    return result
}

