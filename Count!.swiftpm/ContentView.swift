import SwiftUI

struct ContentView: View {
    @StateObject private var game = BlackjackGame()
    @State private var betAmount: String = ""
    @State private var initialChipCount: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showCountAlert: Bool = false
    @State private var isShowingChipSelection: Bool = true
    @State private var firstRound: Bool = true  
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.black]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Count!")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                
                if isShowingChipSelection {
                    VStack(spacing: 20) {
                        Text("Set Your Initial Chips")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Initial Chips", text: $initialChipCount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(maxWidth: 200)
                            .padding(.horizontal)
                        
                        Button("Start Game") {
                            newGame()
                        }
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)
                } else {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Chips: \(game.player.chips)")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Cards Left: \(game.deck.cards.count)")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Dealer's Hand:")
                                .font(.headline)
                                .foregroundColor(.white)
                            HStack {
                                if game.dealerRevealed {
                                    ForEach(game.dealer.hand, id: \.self) { card in
                                        Image(card.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 150)
                                    }
                                } else {
                                    if let firstCard = game.dealer.hand.first {
                                        Image(firstCard.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 150)
                                        Image("bicycle_blue@1x.png")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 150)
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Player's Hand:")
                                .font(.headline)
                                .foregroundColor(.white)
                            HStack {
                                ForEach(game.player.hand, id: \.self) { card in
                                    Image(card.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 150)
                                }
                            }
                        }
                        
                        if game.gameInProgress {
                            HStack(spacing: 15) {
                                Button("Hit") {
                                    game.playerHit()
                                }
                                .padding()
                                .frame(minWidth: 80, minHeight: 40)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .contentShape(Rectangle())
                                
                                Button("Stand") {
                                    game.playerStand()
                                }
                                .padding()
                                .frame(minWidth: 80, minHeight: 40)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .contentShape(Rectangle())                                
                                if game.player.hand.count == 2 && !game.didDoubleDown {
                                    Button("Double Down") {
                                        game.playerDoubleDown()
                                    }
                                    .padding()
                                    .frame(minWidth: 80, minHeight: 40)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .contentShape(Rectangle())
                                }
                                
                                if let firstCard = game.dealer.hand.first,
                                   firstCard.rank == "A",
                                   game.insuranceBet == 0,
                                   game.player.hand.count == 2 {
                                    Button("Insurance") {
                                        game.takeInsurance()
                                    }
                                    .padding()
                                    .frame(minWidth: 80, minHeight: 40)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .contentShape(Rectangle())
                                }
                            }
                        } else {
                            VStack(spacing: 20) {
                                TextField("Enter Bet Amount", text: $betAmount)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .frame(maxWidth: 200)
                                    .padding(.horizontal)
                                
                                HStack {
                                    Button("Place Bet") {
                                        placeBet()
                                    }
                                    .padding()
                                    .frame(maxWidth: 100)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .contentShape(Rectangle())
                                    
                                    if !firstRound {
                                        Button("Same Bet") {
                                            placeSameBet()
                                        }
                                        .padding()
                                        .frame(maxWidth: 100)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .contentShape(Rectangle())
                                    }
                                }
                            }
                        }
                        
                        if !isShowingChipSelection && !firstRound {
                            Button("Show Running Count") {
                                showCountAlert = true
                            }
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                        }
                        
                        if !isShowingChipSelection {
                            Button("New Game") {
                                isShowingChipSelection = true
                                firstRound = true
                            }
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                        }
                        
                        ScrollView {
                            Text(game.gameLog)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Text(game.gameStatus)
                            .font(.title2)
                            .foregroundColor(.yellow)
                            .padding()
                    }
                    .padding()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showCountAlert) {
            Alert(
                title: Text("Running Count"),
                message: Text(
            """
            The current running count is: \(game.runningCount)
            
            The Hi-Lo counting system is one of the most popular card counting strategies used in blackjack to track the ratio of high to low cards remaining in the deck.
            
            - Cards 2-6: +1 (low cards)
            - Cards 7-9: 0 (neutral cards)
            - Cards 10, J, Q, K, A: -1 (high cards)
            
            1. Keep a running count based on the cards dealt.
            2. A higher count means more high cards are left, favoring the player.
            3. Increase your bet when the count is high, and decrease when low! The more you can take advantage over knowing the count, the better.
            """
                ),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func placeBet() {
        guard let bet = Int(betAmount), bet > 0 else {
            alertMessage = "Please enter a valid bet amount."
            showAlert = true
            return
        }
        if bet > game.player.chips {
            alertMessage = "You don't have enough chips to place this bet."
            showAlert = true
            return
        }
        game.player.bet = bet
        game.player.chips -= bet
        game.lastBet = bet  
        betAmount = ""
        game.dealInitialCards()
        firstRound = false
    }
    
    func placeSameBet() {
        let bet = game.lastBet
        if bet <= 0 {
            alertMessage = "No previous bet found."
            showAlert = true
            return
        }
        if bet > game.player.chips {
            alertMessage = "You don't have enough chips to place the same bet."
            showAlert = true
            return
        }
        game.player.bet = bet
        game.player.chips -= bet
        betAmount = ""
        game.dealInitialCards()
        firstRound = false
    }
    
    func newGame() {
        guard let chips = Int(initialChipCount), chips > 0 else {
            alertMessage = "Please enter a valid chip count."
            showAlert = true
            return
        }
        game.resetGame(newChipCount: chips)
        isShowingChipSelection = false
    }
}
