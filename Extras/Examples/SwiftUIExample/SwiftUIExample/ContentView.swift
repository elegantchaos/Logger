//
//  ContentView.swift
//  SwiftUIExample
//
//  Created by Sam Deane on 03/04/2023.
//  Copyright © 2023 Elegant Chaos. All rights reserved.
//

import Logger
import LoggerUI
import SwiftUI

let contentChannel = Channel("Content")

struct ContentView: View {
    var body: some View {
        contentChannel.log("body called")
        
        return NavigationStack {
            List {
                Section(header: Text("Settings")) {
                    
                    NavigationLink(destination: LoggerChannelsView().listStyle(.plain)) {
                        Text("Channels")
                    }
                }
            }
            
            //        .listStyle(GroupedListStyle())
            .padding()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
