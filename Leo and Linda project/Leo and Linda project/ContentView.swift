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
    var round:Int = 1
    
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
        NavigationView {
            ScrollView {
                VStack {
                    Spacer()
                    Image("picksked")
                        .resizable()
                        .frame(width: 100.0, height: 100.0)
                    Spacer()
                    HStack{
                 
                        Text("number of players:")
                            .padding(.leading, 50.0)
                        Spacer()
                        TextField("number of players", text: $numPlayers)
                            .foregroundColor(Color.white)
                            .padding()
                            .frame(width: 65.0, height:30)
                            .background(Color.green)
                            .keyboardType(.decimalPad)
                            .onChange(of: numPlayers) { newValue in
                                if Int(numPlayers) ?? 0 > 3{
                                    playerNames = Array(repeating: "", count: Int(numPlayers) ?? 0)
                                    numPlayersText="Enter the names of your \(numPlayers) players below"
                                }
                                else {numPlayersText="you must have at leaast 4 players"}
                            }
                     
                    }
                    .padding(.trailing, 50.0)
                    Text(numPlayersText)
                    ForEach(0..<playerNames.count, id: \.self) { index in
                        TextField("Player \(index + 1)", text: $playerNames[index])
                            .padding(.horizontal, 50.0)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack{
                 
                        Text("number of courts:")
                            .padding(.leading, 50.0)
                        Spacer()
                        TextField("number of courts", text: $numCourts)
                            
                            .foregroundColor(Color.white)
                            .padding()
                            .frame(width: 65.0, height:30)
                            .background(Color.green)
                            .keyboardType(.decimalPad)
                
                    }
                    .padding(.trailing, 50.0)
                    HStack{
                   
                        Text("games per player:")
                            .padding(.leading, 50.0)
                        Spacer()
                        TextField("number of games per player", text: $numGamesPlayedPerPlayer)
                            .foregroundColor(Color.white)
                            .padding()
                            .frame(width: 65.0, height:30)
                            .background(Color.green)
                            .keyboardType(.decimalPad)
                    
                    }
                    .padding(.trailing, 50.0)
                    Spacer()
                    NavigationLink(destination: ScheduleView(schedule: schedule, numCourts: numCourts ).onAppear(perform: setText)) {
                        Text("Generate Schedule")
                            .foregroundColor(Color.white)
                            .frame(width: 200.0, height: 50.0)
                            .background(Color.green)
                            .padding()
                    }
                    .padding()
                    
                }
                .padding()
                Spacer()
            }
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
    struct Round: Identifiable {
        let id = UUID()
        let roundNumber: Int
        let games: [Team]
    }

    let schedule: [Team]
    let numCourts: String

    var rounds: [Round] {
        schedule.chunked(into: Int(numCourts) ?? 1).enumerated().map { (index, chunk) in
            return Round(roundNumber: index + 1, games: chunk)
        }
    }

    init(schedule: [Team], numCourts: String) {
        self.schedule = schedule
        self.numCourts = numCourts
    }
    var body: some View {
        VStack {
            Text("Generated Schedule")
                .font(.largeTitle)
                .padding()

            // Display the schedule here
            ForEach(rounds) { round in
                         VStack {
                             Text("Round \(round.roundNumber)")
                                 .font(.title2)
                            

                             ForEach(round.games, id: \.id) { team in
                                 Text(team.description)
                                     .font(.footnote)
                             }
                         }
                         .id(round.id) // Specify the id for the outer ForEach
                     }

                     Spacer()
                 }
                 .padding()
    }
}

#Preview {
    ContentView()
}
