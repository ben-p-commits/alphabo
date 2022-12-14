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
    
    let letters = "abcdefghijklmnopqrstuvwxyz".uppercased().map { String($0) }
    
    
    @EnvironmentObject
    var vm: LessonViewModel
    
    var body: some View {
        GeometryReader { proxy in
            TabView(selection: $vm.selectedIndex) {
                ForEach(Array(letters.enumerated()), id: \.offset) { index, letter in
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
    }
    
    func play() {
        Task.init {
            try await vm.playLetter(letterIndex: vm.selectedIndex)
        }
    }
}

struct LetterView: View {
    let letter: String
    let index: Int
    
    let fontLarge: Font
    let fontSmall: Font
    
    let colorC: Color
    let colorA: Color
    let colorB: Color
    
    @EnvironmentObject
    var vm: LessonViewModel
    
    @State var appear = false
    
    init(letter: String, index: Int) {
        
        let fontName = "Krungthep"
        self.index = index
        self.letter = letter
        self.fontLarge = .custom(fontName, size: 270)
        self.fontSmall = .custom(fontName, size: 210)
        
        self.colorA = Color.random
        self.colorB = Color.random
        self.colorC = Color.random
        
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 30.0, style: .continuous)
                .irregularGradient(colors: [colorC, colorA, colorB], background: colorB)
                .mask {
                    HStack(alignment: .bottom) {
                        Group {
                            Text(letter.uppercased())
                                .font(fontLarge)
                            +
                            Text(letter.lowercased())
                                .font(fontSmall)
                        }
                        .shadow(radius: 4, x: 2, y: 2)
                        .fixedSize()
                        .scaleEffect(x: appear ? 1.0 : 1.4, y: appear ? 1.0 : 1.4)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: appear)
                    }
                }
        }
        .onAppear {
            if index == 0 {
                appear = true
            }
        }
        .onChange(of: vm.selectedIndex, perform: { newValue in
            appear = (newValue == index)
        })
    }
}

struct LetterView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            LetterView(letter: "w", index: 0)
            LetterView(letter: "m", index: 1)
            LetterView(letter: "y", index: 2)
        }.tabViewStyle(.page)
            .environmentObject(LessonViewModel())
    }
}

class LessonViewModel: NSObject, ObservableObject{
    @Published var selectedIndex = 0
    
    private var players: [AVAudioPlayer]
    private let synthesizer: AVSpeechSynthesizer
    
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

