import SwiftUI

struct BackgroundView: View{
    var body: some View{
        ZStack {
            // Чёрный фон
            Color(red: 0.03, green: 0.03, blue: 0.03)
                .ignoresSafeArea()
            
            // Нижний фиолетовый блюр
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 98/255, green: 0, blue: 255/255).opacity(0.7), location: 0),
                    .init(color: .clear, location: 1)
                ]),
                center: UnitPoint(x: -0.1, y: 0.75),
                startRadius: 0,
                endRadius: 250
            )
            .ignoresSafeArea()
            
            // Верхний фиолетовый блюр
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 124/255, green: 41/255, blue: 255/255).opacity(0.7), location: 0),
                    .init(color: .clear, location: 1)
                ]),
                center: UnitPoint(x: 1, y: 0.25),
                startRadius: 0,
                endRadius: 250
            )
            .ignoresSafeArea()
        }
    }
    
}
