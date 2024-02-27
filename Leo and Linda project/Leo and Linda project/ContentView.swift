//
//  ContentView.swift
//  Pickleball Game Scheduler
//
//  Created by Linda Woo on 12/26/23.
//

import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

struct ScheduleView: View {
    @Environment(\.colorScheme) var colorScheme
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
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    VStack {
                        Text("Pickleball Shuffle")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .padding()
                       if colorScheme == .dark {
                        Image("icon") // Use the dark mode image
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding(.bottom, 20)
                    } else {
                        Image("cindypickle 1") // Use the light mode image
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding(.bottom, 20)
                    }
                           
                    }
                    Spacer()
                }
                ForEach(rounds) { round in
                    VStack(alignment: .center) {
                        Text("Round \(round.roundNumber)")
                            .font(.title)
                        
                        // Use the gameDescriptions method from Round to display each game with its number
                        ForEach(round.gameDescriptions(), id: \.self) { gameDescription in
                            Text(gameDescription)
                                .font(.footnote)
                                .padding()
                                .frame(minWidth: 150)
                                .background(Color.green)
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

struct ContentView: View {
    @State var numPlayers: String = ""
    @State var numCourts: String = ""
    @State var numPlayersText: String = ""
    @State var courtsNumText: String = ""
    @State var courts: String = "courts"
    @State var schedule = [[Game]]()
    @State private var playerName: String = ""
    @State private var players: [String] = []
    @State var enterPlayersText: String = "Enter at least 4 players:"
    
    func genSchedule() {
        guard let playersNum = Int(numPlayers),
              let courtsNum = Int(numCourts) else {
            self.numPlayersText = "Invalid input. Please enter valid numbers."
            return
        }
        
        schedule = generateSchedule(numPlayers: playersNum, numCourts: courtsNum, playerNames: players)
    }
    
    // Check if all player names are filled out
    func allPlayerNamesFilled() -> Bool {
        return !players.contains { $0.isEmpty }
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
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Pickleball Shuffle")
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .padding()
                            Image("cindypickle 1")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .padding(.bottom, 20)
                        }
                        Spacer()
                    }
                    Text(enterPlayersText)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.red)
                        .padding(.bottom)
                    Text("Total number of players: \(players.count)")
                        .padding(.bottom)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    Group {
                        // Single input field for player name
                        HStack(alignment: .top){
                            TextField("Enter Player Name", text: $playerName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            // Button to add player
                            Button(action: {
                                if !playerName.isEmpty {
                                    players.append(playerName)
                                    playerName = ""
                                    numPlayers = String(players.count)
                                    enterPlayersText = players.count > 3 ? "": "Enter at least 4 players:"
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title)
                            }
                        }
                        .padding(.bottom)
                        
                        // List of players with delete button
                        ForEach(players, id: \.self) { player in
                            HStack {
                                Text(player)
                                    .foregroundColor(.gray)
                                Spacer()
                                Button(action: {
                                    if let index = players.firstIndex(of: player) {
                                        players.remove(at: index)
                                        numPlayers = String(players.count)
                                        enterPlayersText = players.count > 3 ? "": "Enter at least 4 players:"
                                    }
                                }) {
                                    Image(systemName: "x.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                                           .fill(Color.white)
                                                           .border(Color.gray))
                        }
                        .padding(.bottom)
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
                    
                    Spacer(minLength: 20)
                   
                    
                    NavigationLink(
                        destination: scheduleDestinationView,
                        label: {
                            HStack{
                                Spacer()
                                Text("Generate Schedule")
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50, alignment: .center)
                                    .background(Color.green)
                                    .cornerRadius(10)
                                Spacer()
                            }
                        }
                    )
                    .padding()
                    .disabled(!(Int(numPlayers) ?? 2 > 3 && isPositiveInteger(numCourts) && courtsNumText.isEmpty))
                    .opacity((Int(numPlayers) ?? 2 > 3  && isPositiveInteger(numCourts) && courtsNumText.isEmpty) ? 1.0 : 0.5)
                }
                .padding()
                
            }
        }
    }
    
    // Destination view for the NavigationLink
    private var scheduleDestinationView: some View {
        if isPositiveInteger(numCourts){
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
                .background(Color.green)
                .keyboardType(.decimalPad)
                .cornerRadius(5)
        }
    }
}



    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
