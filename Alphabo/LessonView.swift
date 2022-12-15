//
//  ContentView.swift
//  Alphabo
//
//  Created by Benjamin Palmer on 12/6/22.
//

import SwiftUI
import AVFoundation
import IrregularGradient

struct LessonView: View {
    
    @EnvironmentObject
    var vm: LessonViewModel
    
    var body: some View {
        ZStack {
            ProgressionView()
                .environmentObject(vm)
            GeometryReader { proxy in
                TabView(selection: $vm.selectedIndex) {
                    ForEach(Array(vm.letters.enumerated()), id: \.offset) { index, letter in
                        LetterView(letter: letter, index: index)
                            .environmentObject(vm)
                        .tag(index)
                    }
                    .rotationEffect(.degrees(-90))
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height
                    )
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onAppear(perform: play)
                .onChange(of: vm.selectedIndex) { _ in play() }
                // layout modifiers for vertical scrolling
                .frame(
                    width: proxy.size.height,
                    height: proxy.size.width
                )
                .rotationEffect(.degrees(90), anchor: .topLeading)
                .offset(x: proxy.size.width)
            }
            .ignoresSafeArea()
        }
        
    }
    
    func play() {
        Task.init {
//            try await vm.playLetter(letterIndex: vm.selectedIndex)
        }
    }
}

struct ProgressionView: View {
    @EnvironmentObject
    var vm: LessonViewModel
    
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                Spacer()
                VStack {
                    ForEach(Array(vm.letters.enumerated()), id: \.offset) { index, letter in
                        Circle()
                            .fill(.blue.opacity(index == vm.selectedIndex ? 0.2 : 0))
                            .frame(height: 32)
                            .overlay(
                                Text(letter)
                                    .font(index == vm.selectedIndex ? .headline : .body)
                            )
                        Spacer()
                    }
                }
            }
            .animation(.easeOut, value: vm.selectedIndex)
            .offset(y: (geo.size.height / 2.0) - offsetStepSize(height: geo.size.height))
        }
        .padding(.horizontal, 4)
    }
    
    func offsetStepSize(height: CGFloat) -> CGFloat {
        CGFloat(vm.selectedIndex * (Int(height) / vm.letters.count))
    }
}

class LessonViewModel: NSObject, ObservableObject{
    @Published var selectedIndex = 0
    
    private var players: [AVAudioPlayer]
    private let synthesizer: AVSpeechSynthesizer
    
    let letters = "abcdefghijklmnopqrstuvwxyz".uppercased().map { String($0) }
    
    override init() {
        self.selectedIndex = 0
        self.players = [AVAudioPlayer]()
        self.synthesizer = AVSpeechSynthesizer()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    func playUtterance(letter: String) async {
        let utterance = AVSpeechUtterance(string: "'\(letter)'")
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.language.languageCode?.identifier)
        synthesizer.speak(utterance)
    }
    
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
            .environmentObject(LessonViewModel())
    }
}

