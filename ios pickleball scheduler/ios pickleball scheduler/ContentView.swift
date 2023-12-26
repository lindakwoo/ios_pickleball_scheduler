//
//  ContentView.swift
//  Pickleball Game Scheduler
//
//  Created by Linda Woo on 12/26/23.
//

import SwiftUI
import utils

struct ContentView: View {
    @State var numPlayers: String = ""
    @State var numCourts: String = ""
    @State var numGamesPlayedPerPlayer: String = ""
    @State var numPlayersText: String=""
    @State var courts:String="courts"
    
    func setText(){
        if numCourts == "1" {
            courts="court"
        }
        numPlayersText="You have entered \(numPlayers) players on \(numCourts) \(courts) and each player will play \(numGamesPlayedPerPlayer) games."
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
                Spacer()
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
            Text(numPlayersText)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
