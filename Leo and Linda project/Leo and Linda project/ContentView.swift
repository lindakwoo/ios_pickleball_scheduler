//
//  ContentView.swift
//  Pickleball Game Scheduler
//
//  Created by Linda Woo on 12/26/23.
//

import SwiftUI

struct ContentView: View {
    @State var numPlayers: String = ""
    @State var numCourts: String = ""
    @State var numGamesPlayedPerPlayer: String = ""
    @State var numPlayersText: String = "Enter player details"
    @State var courts: String = "courts"
    @State var schedule = [[Game]]()  // Updated to reflect the new structure
    @State private var playerNames: [String] = []
    
    func setText() {
        guard let playersNum = Int(numPlayers),
              let courtsNum = Int(numCourts),
              let gamesNum = Int(numGamesPlayedPerPlayer) else {
            self.numPlayersText = "Invalid input. Please enter valid numbers."
            return
        }

        if courtsNum == 1 {
            courts = "court"
        } else {
            courts = "courts"
        }

        schedule = generateSchedule(numPlayers: playersNum, numCourts: courtsNum, gamesPerPlayer: gamesNum, playerNames: playerNames)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Image("picksked")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 20)

                    Group {
                        InputFieldView(label: "Number of players:", text: $numPlayers, placeholder: "Enter number of players")
                            .onChange(of: numPlayers) { newValue in
                                if let playerCount = Int(numPlayers), playerCount > 3 {
                                    playerNames = Array(repeating: "", count: playerCount)
                                    numPlayersText = "Enter the names of your \(playerCount) players below"
                                } else {
                                    numPlayersText = "You must have at least 4 players"
                                }
                            }
                        
                        Text(numPlayersText)
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        ForEach(0..<playerNames.count, id: \.self) { index in
                            TextField("Player \(index + 1)", text: $playerNames[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        InputFieldView(label: "Number of courts:", text: $numCourts, placeholder: "Enter number of courts")
                        InputFieldView(label: "Games per player:", text: $numGamesPlayedPerPlayer, placeholder: "Enter games per player")
                    }

                    Spacer(minLength: 20)
                    
                    NavigationLink(destination: ScheduleView(schedule: schedule, numCourts: numCourts).onAppear(perform: setText)) {
                        Text("Generate Schedule")
                            .foregroundColor(.white)
                            .frame(minWidth: 200, minHeight: 50)
                            .background(Color.cyan)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Pickleball Game Scheduler")
        }
    }
}

struct InputFieldView: View {
    var label: String
    @Binding var text: String
    var placeholder: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .padding(10)
                .frame(height: 44)
                .background(Color.cyan)
                .keyboardType(.decimalPad)
                .cornerRadius(5)
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

struct ScheduleView: View {
    let schedule: [[Game]]  // Schedule is now an array of rounds, each containing an array of Games
    let numCourts: String

    // Compute rounds based on the schedule provided
    var rounds: [Round] {
        schedule.enumerated().map { (index, games) in
            Round(roundNumber: index + 1, games: games)
        }
    }

    init(schedule: [[Game]], numCourts: String) {
        self.schedule = schedule
        self.numCourts = numCourts
    }
    var body: some View {
        ScrollView {
            VStack {
                Text("Generated Schedule")
                    .font(.largeTitle)
                    .padding()
                
                // Display the schedule here
                ForEach(rounds) { round in
                    VStack {
                        Text("Round \(round.roundNumber)")
                            .font(.title)
                            .padding()
                        
                        // Use the gameDescriptions method from Round to display each game with its number
                        ForEach(round.gameDescriptions(), id: \.self) { gameDescription in
                            Text(gameDescription)
                                .padding()
                                .frame(minWidth: 150)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 20) // Add some space between each round
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
