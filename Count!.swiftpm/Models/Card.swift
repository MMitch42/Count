struct Card: Hashable {
    let suit: String
    let rank: String
    let countValue: Int  
    
    init(suit: String, rank: String) {
        self.suit = suit
        self.rank = rank
        self.countValue = Card.calculateCount(rank: rank)
    }
    
    static func calculateCount(rank: String) -> Int {
        switch rank {
        case "2", "3", "4", "5", "6":
            return 1
        case "7", "8", "9":
            return 0
        case "10", "J", "Q", "K", "A":
            return -1
        default:
            return 0
        }
    }
    
    var gameValue: Int {
        if let num = Int(rank) {
            return num
        } else if rank == "A" {
            return 11 // can conditionally return 1 in Player and Dealer
        } else {
            return 10  
        }
    }
    
    var imageName: String {
        let suitLetter: String
        switch suit {
        case "Hearts":
            suitLetter = "H"
        case "Diamonds":
            suitLetter = "D"
        case "Clubs":
            suitLetter = "C"
        case "Spades":
            suitLetter = "S"
        default:
            suitLetter = ""
        }
        return "\(rank)\(suitLetter)@1x.png"
    }
    
    func cardDisplay() -> String {
        let suitEmoji: String
        switch suit {
        case "Hearts":
            suitEmoji = "❤️"
        case "Diamonds":
            suitEmoji = "♦️"
        case "Clubs":
            suitEmoji = "♣️"
        case "Spades":
            suitEmoji = "♠️"
        default:
            suitEmoji = ""
        }
        return "\(rank) \(suitEmoji)"
    }
}
