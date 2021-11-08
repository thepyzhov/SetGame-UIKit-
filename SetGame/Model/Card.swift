//
//  Card.swift
//  SetGame
//
//  Created by Dmitry Pyzhov on 31.08.2021.
//

import Foundation

struct Card {
    let number: Attributes
    let shape: Attributes
    let shading: Attributes
    let color: Attributes
    
    enum Attributes: Int, CaseIterable {
        case first = 0
        case second
        case third
        
        var value: Int { return self.rawValue + 1 }
    }
    
    static func isSet(of cards: [Card]) -> Bool {
        let set = [
            cards.reduce(0, { $0 + $1.number.rawValue }),
            cards.reduce(0, { $0 + $1.shape.rawValue }),
            cards.reduce(0, { $0 + $1.shading.rawValue }),
            cards.reduce(0, { $0 + $1.color.rawValue })
        ]
        return set.reduce(true, { $0 && (($1 % 3) == 0) })
        //return true
    }
}

extension Card: Equatable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.number == rhs.number
            && lhs.shape == rhs.shape
            && lhs.shading == rhs.shading
            && lhs.color == rhs.color
    }
}
