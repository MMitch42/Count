import SwiftUI

@main
struct BlackjackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class BlackjackGame: ObservableObject {
    // @Published auto-updates when values are changed 
    @Published var deck: Deck
    @Published var player: Player
    @Published var dealer: Dealer
    @Published var runningCount: Int = 0
    @Published var gameInProgress: Bool = false
    @Published var dealerRevealed: Bool = false
    @Published var gameLog: String = ""  
    @Published var gameStatus: String = "" 
    @Published var lastBet: Int = 0   
    // don't update UI, so not @Published 
    var dealerHiddenCardCounted: Bool = false
    var insuranceBet: Int = 0
    var didDoubleDown: Bool = false
    
    init() {
        self.deck = Deck()
        self.player = Player()
        self.dealer = Dealer()
    }
    
    func drawCard() -> Card? {
        if deck.cards.isEmpty {
            deck.resetDeck()
            runningCount = 0
            gameLog += "\nDeck was automatically reshuffled.\n"
        }
        return deck.drawCard()
    }
    
    func resetGame(newChipCount: Int) {
        deck.resetDeck()              
        runningCount = 0              
        player.resetHand()
        dealer.resetHand()
        player.chips = newChipCount    
        player.bet = 0
        gameLog = ""
        gameStatus = ""
        gameInProgress = false
        dealerRevealed = false
        dealerHiddenCardCounted = false
        insuranceBet = 0
        didDoubleDown = false
        lastBet = 0
    }
    
    func startNewGame() {
        player.resetHand()
        dealer.resetHand()
        gameStatus = ""
        gameLog = ""
        dealerRevealed = false
        dealerHiddenCardCounted = false
        insuranceBet = 0
        didDoubleDown = false
    }
    
    func updateCount(card: Card) {
        runningCount += card.countValue
    }
    
    func dealInitialCards() {
        player.resetHand()
        dealer.resetHand()
        gameStatus = ""
        gameLog = ""
        dealerRevealed = false
        dealerHiddenCardCounted = false
        insuranceBet = 0
        didDoubleDown = false
        
        if let card1 = drawCard(),
           let card2 = drawCard(),
           let card3 = drawCard(),
           let card4 = drawCard() {
            player.addCard(card1)
            player.addCard(card2)
            updateCount(card: card1)
            updateCount(card: card2)
            dealer.addCard(card3)
            updateCount(card: card3)
            // second card not counted until revealed
            dealer.addCard(card4)
        }
        gameInProgress = true
    }
    
    func playerHit() {
        if let card = drawCard() {
            player.addCard(card)
            updateCount(card: card)
        }
        if player.calculateHandValue() > 21 {
            gameStatus = "Bust! Dealer wins!"
            gameInProgress = false
        }
    }
    
    func playerDoubleDown() {
        guard gameInProgress, player.hand.count == 2, !didDoubleDown else { return }
        if player.chips < player.bet {
            gameLog += "\nNot enough chips to double down."
            return
        }
        // double the bet 
        player.chips -= player.bet
        player.bet *= 2
        didDoubleDown = true
        
        // give one last card 
        if let card = drawCard() {
            player.addCard(card)
            updateCount(card: card)
        }
        
        // force player to stand 
        playerStand()
    }
    
    func takeInsurance() {
        guard gameInProgress,
              dealer.hand.count >= 1,
              // .first? ensures that program wouldn't crash if dealer hand happens to be empty
              dealer.hand.first?.rank == "A",
              insuranceBet == 0 else { return }
        
        let insBet = player.bet / 2
        if player.chips < insBet {
            gameLog += "\nNot enough chips for insurance."
            return
        }
        player.chips -= insBet
        insuranceBet = insBet
        gameLog += "\nInsurance taken: \(insBet) chips."
    }
    
    func playerStand() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.dealer.hand.count >= 2 && !self.dealerHiddenCardCounted {
                self.updateCount(card: self.dealer.hand[1])
                self.dealerHiddenCardCounted = true
                self.gameLog += "\nDealer's facedown card is revealed: \(self.dealer.hand[1].cardDisplay())\n"
            }
            self.dealerRevealed = true
            
            if self.dealer.hand.count == 2 && self.dealer.calculateHandValue() == 21 {
                self.gameLog += "\nDealer has blackjack!"
                if self.insuranceBet > 0 {
                    let payout = self.insuranceBet * 2
                    self.player.chips += payout
                    self.gameLog += "\nInsurance pays out \(payout) chips."
                }
                
                if self.player.calculateHandValue() == 21 {
                    self.gameStatus = "Push! Both have blackjack."
                    self.player.chips += self.player.bet
                } else {
                    self.gameStatus = "Dealer blackjack! You lose."
                }
                self.gameInProgress = false
                return
            }
            
            self.gameLog += "Dealer's turn to play...\n"

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                func dealerDraw() {
                    if self.dealer.calculateHandValue() < 17 {
                        if let card = self.drawCard() {
                            self.dealer.addCard(card)
                            self.updateCount(card: card)
                            self.gameLog += "Dealer drew: \(card.cardDisplay())\n"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                dealerDraw()
                            }
                        } else {
                            self.gameLog += "No more cards in deck.\n"
                            self.gameInProgress = false
                            self.resolveGame()
                        }
                    } else {
                        self.gameLog += "Game over. Final dealer hand value: \(self.dealer.calculateHandValue())"
                        self.gameInProgress = false
                        self.resolveGame()
                    }
                }
                
                dealerDraw()
            }
        }
    }
    
    func resolveGame() {
        let playerValue = player.calculateHandValue()
        let dealerValue = dealer.calculateHandValue()
        
        if playerValue > 21 {
            gameStatus = "Bust! Dealer wins!"
        } else if dealerValue > 21 {
            gameStatus = "Dealer busts! You win!"
            player.chips += player.bet * 2
        } else if playerValue == dealerValue {
            gameStatus = "Push!"
            player.chips += player.bet
        } else if playerValue > dealerValue {
            gameStatus = "You win!"
            player.chips += player.bet * 2
        } else {
            gameStatus = "Dealer wins!"
        }
    }
}
