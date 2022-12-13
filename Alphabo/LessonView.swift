//
//  ContentView.swift
//  Alphabo
//
//  Created by Benjamin Palmer on 12/6/22.
//

import SwiftUI

struct LessonView: View {
    let letters = "abcdefghijklmnopqrstuvwxyz".uppercased().map { String($0) }
    
    @State private var selectedTab = 0
    
    var body: some View {
        GeometryReader { proxy in
            TabView(selection: $selectedTab) {
                ForEach(Array(letters.enumerated()), id: \.offset) { index, letter in
                    VStack {
                        Text(letter)
                            .font(.custom("Futura", size: 270))
                        Text("selected tab is: \(letters[selectedTab])")
                    }
                    .tag(index)
                }
                .rotationEffect(.degrees(-90))
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height
                )
            }
            .frame(
                width: proxy.size.height,
                height: proxy.size.width
            )
            .rotationEffect(.degrees(90), anchor: .topLeading)
            .offset(x: proxy.size.width)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: selectedTab) { newValue in
                print("changed to \(newValue)")
            }
        }
    }
}

struct LessonView_Previews: PreviewProvider {
    static var previews: some View {
        LessonView()
    }
}

