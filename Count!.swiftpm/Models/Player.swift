class Player {
    var hand: [Card] = []
    var chips: Int = 0
    var bet: Int = 0
    
    func addCard(_ card: Card) {
        hand.append(card)
    }
    
    func resetHand() {
        hand = []
    }
    
    func calculateHandValue() -> Int {
        var total = 0
        var aceCount = 0
        
        for card in hand {
            total += card.gameValue
            if card.rank == "A" {
                aceCount += 1
            }
        }
        
        // make ace go from 11 to 1 if total value is over 21
        while total > 21 && aceCount > 0 {
            total -= 10
            aceCount -= 1
        }
        
        return total
    }
}
