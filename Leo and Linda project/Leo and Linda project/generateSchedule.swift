//
//  generateSchedule.swift
//  Leo and Linda project
//
//  Created by Linda Woo on 12/26/23.
//

import Foundation
public func test(){
    print("hello here. i'm here!!")
}

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
        for team in combinations(arr: combination, combinationSize: 2) {
            if !hasBeenTeammates(p1: team[0], p2: team[1]) {
                let remainingPlayers = Set(combination).subtracting([team[0], team[1]])
                let remainingArray = Array(remainingPlayers)
                let otherTeam = (remainingArray[0], remainingArray[1])

                if !hasBeenTeammates(p1: otherTeam.0, p2: otherTeam.1) {
                    teamHistoryTracker[team[0]][team[1]] += 1
                    teamHistoryTracker[team[1]][team[0]] += 1

                    teamHistoryTracker[otherTeam.0][otherTeam.1] += 1
                    teamHistoryTracker[otherTeam.1][otherTeam.0] += 1

                    return ((team[0], team[1]), (otherTeam.0, otherTeam.1))
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
        let validCombinations = combinations(arr: players, combinationSize: 4).filter {
            combination in
            return gamesCounter[combination[0]] < gamesPerPlayer && gamesCounter[combination[1]] < gamesPerPlayer && gamesCounter[combination[2]] < gamesPerPlayer && gamesCounter[combination[3]] < gamesPerPlayer
        }
        
        if validCombinations.isEmpty {
            break
        }
        
        for _ in 0..<numCourts {
            if gamesScheduled >= totalGames {
                break
            }
            
            let leastCombination = validCombinations.reduce(validCombinations[0]) { (min, current) in
                let sumCurrent = current.reduce(0) { $0 + gamesCounter[$1] }
                let sumMin = min.reduce(0) { $0 + gamesCounter[$1] }
                return sumCurrent < sumMin ? current : min
            }
            
            if let (team1, team2) = validTeams(combination: leastCombination) {
                schedule.append((team1: team1, team2: team2))
            }
            gamesScheduled += 1
            
            for combination in combinations(arr: leastCombination, combinationSize: 2) {
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
    
    
    print("here's the schedule \(schedule)")
    return "\(schedule)"
}

    
    func combinations<T>(arr: [T], combinationSize: Int) -> [[T]] {
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
    }
