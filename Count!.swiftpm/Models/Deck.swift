struct Deck {
    var cards: [Card]
    
    init() {
        let suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
        let ranks: [String] = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
        
        self.cards = []
        for suit in suits {
            for rank in ranks {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
        cards.shuffle()
    }
    
    mutating func drawCard() -> Card? {
        return cards.popLast()
    }
    
    mutating func resetDeck() {
        let suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
        let ranks: [String] = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
        
        self.cards = []
        for suit in suits {
            for rank in ranks {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
        cards.shuffle()
    }
}
