//
//  ContentView.swift
//  Alphabo
//
//  Created by Benjamin Palmer on 12/6/22.
//

import SwiftUI
import AVFoundation

struct LessonView: View {
    
    let letters = "abcdefghijklmnopqrstuvwxyz".uppercased().map { String($0) }
    
    
    @StateObject
    var vm = LessonViewModel()
    
    @State private var selectedTab = 0
    
    var body: some View {
        GeometryReader { proxy in
            TabView(selection: $selectedTab) {
                ForEach(Array(letters.enumerated()), id: \.offset) { index, letter in
                    LetterView(letter: letter)
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
                
                Task.init {
                    do {
                        try await vm.playLetter(letterIndex: selectedTab)
                    } catch {
                    }
                }
            }
        }
    }
}

struct LetterView: View {
    let letter: String
    
    let fontLarge: Font
    let fontSmall: Font
    
    init(letter: String) {
        let fontName = "Krungthep"
        self.letter = letter
        self.fontLarge = .custom(fontName, size: 270)
        self.fontSmall = .custom(fontName, size: 210)
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Group {
                    Text(letter)
                        .font(fontLarge)
                    +
                    Text(letter.lowercased())
                        .font(fontSmall)
                }
                .scaledToFill()
                .kerning(-10)
               
            }
        }
    }
}

class LessonViewModel: NSObject, ObservableObject{
    private var players: [AVAudioPlayer] = []
    
    func playLetter(letterIndex: Int) async throws {
        
        let filename = "letter_\(letterIndex + 1)"
        guard let audioData = NSDataAsset(name: filename)?.data else {
            throw "audio asset not found: \(filename)"
        }
        do {
            // create new one, set delegate for cleanup.
            let player = try AVAudioPlayer(data: audioData)
            player.delegate = self
            
            players.append(player)
            players.last?.play()
        } catch {
            throw error
        }
    }
}

extension LessonViewModel: AVAudioPlayerDelegate {
    // when a player finishes, remove it.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) { clearPlayer(player) }
    
    // these are short clips, interruption should cause removal as well.
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) { clearPlayer(player) }
    
    func clearPlayer(_ player: AVAudioPlayer) {
        guard let indexToRemove = players.firstIndex(of: player) else { return }
        print("removing player at: \(indexToRemove)")
        players.remove(at: indexToRemove)
        
    }
}


struct LessonView_Previews: PreviewProvider {
    static var previews: some View {
        LessonView()
    }
}

