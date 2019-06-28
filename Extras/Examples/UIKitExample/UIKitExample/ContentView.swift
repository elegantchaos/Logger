//
//  ContentView.swift
//  Logger Example
//
//  Created by Sam Deane on 28/06/2019.
//  Copyright © 2019 Elegant Chaos. All rights reserved.
//

import SwiftUI
import Logger

let viewChannel = Logger("View")

struct ContentView : View {
    var body: some View {
        VStack {
            Button(action: {
                applicationChannel.log("hello ma!")
            }) {
                Text("Log to application channel")
            }

            Button(action: {
                viewChannel.log("hello ma!")
            }) {
                Text("Log to view channel")
            }
            
        }

    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
