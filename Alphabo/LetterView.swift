//
//  LetterView.swift
//  Alphabo
//
//  Created by Benjamin Palmer on 12/14/22.
//

import SwiftUI
import IrregularGradient

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
