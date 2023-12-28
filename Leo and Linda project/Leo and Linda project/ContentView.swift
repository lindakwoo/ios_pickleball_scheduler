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
    @State var numPlayersText: String=""
    @State var courts:String="courts"
    @State var schedule = [Team]()
    @State private var playerNames: [String] = []
    
    func setText() {
        guard let playersNum = Int(numPlayers),
              let courtsNum = Int(numCourts),
              let gamesNum = Int(numGamesPlayedPerPlayer) else {
            // Handle the case where conversion fails
            // You might want to display an error message or take appropriate action
            return
        }

        if numCourts == "1" {
            courts = "1"
        }

       schedule = generateSchedule(numPlayers: playersNum, numCourts: courtsNum, gamesPerPlayer: gamesNum, playerNames: playerNames)
      
    }
    
    var body: some View {
        VStack {
           Spacer()
            Text("Pickleball Scheduler")
                .font(.largeTitle)
                .padding()
            Spacer()
            HStack{
                Spacer()
                Text("number of players :")
                Spacer()
                TextField("number of players", text: $numPlayers)
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(width: 100.0)
                    .background(Color.cyan)
                    .keyboardType(.decimalPad)
                    .onChange(of: numPlayers) {
                            // Update your logic here based on the new value of numberOfPlayers
                        if Int(numPlayers) ?? 0 > 3{
                            playerNames = Array(repeating: "", count: Int(numPlayers) ?? 0)
                            numPlayersText="Enter the names of your \(numPlayers) players below"
                        }
                        else {numPlayersText="you must have at leaast 4 players"}
                    }
                Spacer()
            }
            Text(numPlayersText)
            ForEach(0..<playerNames.count, id: \.self) { index in
                          TextField("Player \(index + 1)", text: $playerNames[index])
                              .padding()
                              .textFieldStyle(RoundedBorderTextFieldStyle())
                      }
          
            HStack{
                Spacer()
                Text("number of courts:")
                Spacer()
                TextField("number of courts", text: $numCourts)
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(width: 100.0)
                    .background(Color.cyan)
                    .keyboardType(.decimalPad)
                Spacer()
            }
     
            HStack{
                Spacer()
                Text("games per player:")
                Spacer()
                TextField("number of games per player", text: $numGamesPlayedPerPlayer)
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(width: 100.0)
                    .background(Color.cyan)
                    .keyboardType(.decimalPad)
                Spacer()
            }
            Spacer()
            Button(action: {setText()}) {
                Text("submit")
                    .font(.title)
                    .foregroundColor(Color.white)
                    .frame(width: 150.0, height: 50.0)
                    .background(Color.cyan)
                    .padding()
            } .padding()
            Spacer()
            ForEach(schedule) { team in
                Text(team.description)
            }
         
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
