//
//  GameOfSet.swift
//  SetGame
//
//  Created by Dmitry Pyzhov on 01.09.2021.
//

import Foundation

struct GameOfSet {
    private(set) var score = 0 {
        didSet {
            score = score < 0 ? 0 : score
        }
    }
    private(set) var time = 0
    
    private(set) var cards = [Card]()
    private(set) var cardsSelected = [Card]()
    private(set) var cardsOnTable = [Card]()
    private(set) var cardsTryMatched = [Card]()
    
    private var cardsRemoved = [Card]()
    private var hintIndices = [(firstIndex: Int, secondIndex: Int, thirdIndex: Int)]()
    private var hintIndex = 0
    
    var setsCount: Int {
        get {
            return hintIndices.count
        }
    }
    
    private(set) var isSet: Bool? {
        get {
            guard cardsTryMatched.count == Constants.maxNumberCardsInSelection else { return nil }
            return Card.isSet(of: cardsTryMatched)
        }
        set {
            if newValue != nil {
                score = newValue! ? score + ScorePoints.match : score - ScorePoints.mismatch
                
                cardsTryMatched = cardsSelected
                cardsSelected.removeAll()
            } else {
                cardsTryMatched.removeAll()
            }
        }
    }
    
    init() {
        let allAttribuesCases = Card.Attributes.allCases
        for number in allAttribuesCases {
            for shape in allAttribuesCases {
                for shading in allAttribuesCases {
                    for color in allAttribuesCases {
                        cards.append(Card(number: number,
                                          shape: shape,
                                          shading: shading,
                                          color: color))
                    }
                }
            }
        }
        
        for _ in 0..<Constants.startNumberCards {
            if let card = drawCardFromDeck() {
                cardsOnTable.append(card)
            }
        }
        calculateHints()
    }
    
    private mutating func calculateHints() {
        hintIndex = 0
        hintIndices.removeAll()
        
        for firstIndex in 0..<cardsOnTable.count {
            for secondIndex in (firstIndex + 1)..<cardsOnTable.count {
                for thirdIndex in (secondIndex + 1)..<cardsOnTable.count {
                    if firstIndex != secondIndex && firstIndex != thirdIndex && secondIndex != thirdIndex,
                       Card.isSet(of: [cardsOnTable[firstIndex], cardsOnTable[secondIndex], cardsOnTable[thirdIndex]]) {
                        hintIndices.append((firstIndex, secondIndex, thirdIndex))
                    }
                }
            }
        }
    }
    
    mutating func getHint() -> [Int] {
        var hintTuple = [Int]()
        guard !hintIndices.isEmpty else { return hintTuple }
        hintTuple = [hintIndices[hintIndex].firstIndex, hintIndices[hintIndex].secondIndex, hintIndices[hintIndex].thirdIndex]
        hintIndex = hintIndex < setsCount - 1 ? hintIndex + 1 : 0
        return hintTuple
    }
    
    mutating func chooseCard(at index: Int) {
        let cardChosen = cardsOnTable[index]
        guard !cardsRemoved.contains(cardChosen) && !cardsTryMatched.contains(cardChosen) else { return }
        
        if let selectedIndex = cardsSelected.firstIndex(of: cardsOnTable[index]) {
            //score -= ScorePoints.deselection
            cardsSelected.remove(at: selectedIndex)
        } else {
            if cardsSelected.isEmpty {
                if isSet != nil, isSet! {
                    removeMatchedCardsFromTable()
                }
                isSet = nil
            }
            cardsSelected.append(cardChosen)
            calculateHints()
        }

        if cardsSelected.count >= Constants.maxNumberCardsInSelection {
            isSet = Card.isSet(of: cardsSelected)
        }
    }
    
    mutating func shuffleCardsOnTable() {
        cardsOnTable.shuffle()
    }
    
    private mutating func removeMatchedCardsFromTable() {
        if cardsOnTable.count == Constants.startNumberCards, let drawnCards = draw3CardsFromDeck() {
            cardsOnTable.replace(elements: cardsTryMatched, with: drawnCards)
        } else if !cardsOnTable.isEmpty {
            cardsOnTable.remove(elements: cardsTryMatched)
        }
        cardsRemoved += cardsTryMatched
        cardsTryMatched.removeAll()
    }
    
    mutating func add3Cards() {
        if let drawnCards = draw3CardsFromDeck() {
            if isSet != nil && isSet! {
                cardsOnTable.replace(elements: cardsTryMatched, with: drawnCards)
                isSet = nil
            } else {
                cardsOnTable += drawnCards
            }
        }
        calculateHints()
    }
    
    private mutating func draw3CardsFromDeck() -> [Card]? {
        var drawnCards = [Card]()
        for _ in 0..<Constants.addNumberCards {
            if let newCard = drawCardFromDeck() {
                drawnCards.append(newCard)
            } else {
                return nil
            }
        }
        return drawnCards
    }
    
    private mutating func drawCardFromDeck() -> Card? {
        guard !cards.isEmpty else { return nil }
        return cards.remove(at: Int.random(in: 0..<cards.count))
    }
}

// MARK: - Constants

extension GameOfSet {
    private struct Constants {
        static let startNumberCards = 12
        static let addNumberCards = 3
        static let maxNumberCardsInSelection = 3
    }
    
    private struct ScorePoints {
        static let match = 3
        static let mismatch = 5
        static let deselection = 1
    }
}

// MARK: - Array Extension

extension Array where Element: Equatable {
    mutating func replace(elements: [Element], with new: [Element]) {
        guard elements.count == new.count else { return }
        for index in elements.indices {
            if let foundIndex = self.firstIndex(of: elements[index]) {
                self[foundIndex] = new[index]
            }
        }
    }
    
    mutating func remove(elements: [Element]) {
        self = self.filter { !elements.contains($0) }
    }
}
