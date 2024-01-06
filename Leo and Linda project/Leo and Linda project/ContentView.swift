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
    @State var numPlayersText: String = ""
    @State var courtsNumText: String = ""
    @State var gamesPerPlayerText: String = ""
    @State var courts: String = "courts"
    @State var schedule = [[Game]]() 
    @State private var playerNames: [String] = []
    
    func genSchedule() {
         guard let playersNum = Int(numPlayers),
              let courtsNum = Int(numCourts),
              let gamesNum = Int(numGamesPlayedPerPlayer) else {
            self.numPlayersText = "Invalid input. Please enter valid numbers."
            return
        }

        schedule = generateSchedule(numPlayers: playersNum, numCourts: courtsNum, gamesPerPlayer: gamesNum, playerNames: playerNames)
    }

     // Check if all player names are filled out
    func allPlayerNamesFilled() -> Bool {
        return !playerNames.contains { $0.isEmpty }
    }

    func isPositiveInteger(_ input: String) -> Bool {
        if let number = Int(input), number > 0 {
            return true
        }
        return false
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center) {
                    Image("picksked")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 20)

                    Group {
                        InputFieldView(label: "Number of players:", text: $numPlayers, placeholder: "Enter number of players")
                            .onChange(of: numPlayers) { newValue in
                             guard let playersNum = Int(numPlayers) else {
                                    self.numPlayersText = "Please enter a valid number for courts."
                                    return
                                }
                                if let playerCount = Int(numPlayers), playerCount > 3 {
                                    playerNames = Array(repeating: "", count: playerCount)
                                    numPlayersText = !allPlayerNamesFilled() ? "Enter the names of your \(playerCount) players below": ""
                                } else {
                                     playerNames = Array(repeating: "", count: 0)
                                    numPlayersText = "You must have at least 4 players"
                                    
                                }
                            }
                        Text(numPlayersText)
                            .font(.callout)
                            .foregroundColor(.red)
                        
                        ForEach(0..<playerNames.count, id: \.self) { index in
                            TextField("Player \(index + 1)", text: $playerNames[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of:playerNames[index]){newValue in
                                numPlayersText = !allPlayerNamesFilled() ? "Enter the names of your \(numPlayers) players below": "" }
                        }
                        
                        InputFieldView(label: "Number of courts:", text: $numCourts, placeholder: "Enter number of courts")
                            .onChange(of: numCourts) { newValue in
                                guard let playersNum = Int(numPlayers), let courtsNum = Int(newValue) else {
                                    self.courtsNumText = "Please enter a valid number for courts."
                                    return
                                }
                                let maxCourtsAllowed = playersNum/4
                                self.courtsNumText = courtsNum > maxCourtsAllowed ? "Input exceeds limit: Maximum \(maxCourtsAllowed) courts." : ""
                            }
                        Text(courtsNumText)
                            .font(.callout)
                            .foregroundColor(.red)

                        InputFieldView(label: "Games per player:", text: $numGamesPlayedPerPlayer, placeholder: "Enter games per player")
                            .onChange(of: numGamesPlayedPerPlayer) { newValue in
                                guard let gamesNum = Int(newValue), let playersNum = Int(numPlayers) else {
                                    self.gamesPerPlayerText = "Please enter a valid number for games."
                                    return
                                }
                                let maxGamesPerPlayerAllowed = playersNum-1
                                self.gamesPerPlayerText = gamesNum > maxGamesPerPlayerAllowed ? "Input exceeds limit: Maximum \(maxGamesPerPlayerAllowed) games per player.": ""
                            }
                        Text(gamesPerPlayerText)
                            .font(.callout)
                            .foregroundColor(.red)
                    }

                    Spacer(minLength: 20)
                    
                    NavigationLink(
                        destination: scheduleDestinationView,
                        label: {
                            Text("Generate Schedule")
                                .foregroundColor(.white)
                                .frame(minWidth: 200, minHeight: 50)
                                .background(Color.cyan)
                                .cornerRadius(10)
                        }
                    )
                    .padding()
                    .disabled(!(allPlayerNamesFilled() && isPositiveInteger(numCourts) && isPositiveInteger(numGamesPlayedPerPlayer) && courtsNumText.isEmpty && gamesPerPlayerText.isEmpty))
                    .opacity(allPlayerNamesFilled() && isPositiveInteger(numCourts) &&  courtsNumText.isEmpty && gamesPerPlayerText.isEmpty && isPositiveInteger(numGamesPlayedPerPlayer) ? 1.0 : 0.5 )
                }
                .padding()
             
            }
            .navigationTitle("Pickleball Scheduler")
        }
    }

    // Destination view for the NavigationLink
    private var scheduleDestinationView: some View {
        if allPlayerNamesFilled() && isPositiveInteger(numCourts) && isPositiveInteger(numGamesPlayedPerPlayer){
           // Set the text before navigating
            return AnyView(ScheduleView(schedule: schedule, numCourts: numCourts).onAppear(perform: genSchedule))
        } else {
            return AnyView(
                VStack {
                    Text("All player names must be filled out.")
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                }
            )
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
                ForEach(rounds) { round in
                    VStack {
                        Text("Round \(round.roundNumber)")
                            .font(.title)
                        
                        // Use the gameDescriptions method from Round to display each game with its number
                        ForEach(round.gameDescriptions(), id: \.self) { gameDescription in
                            Text(gameDescription)
                                .font(.footnote)
                                .padding()
                                .frame(minWidth: 150)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 20)
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
