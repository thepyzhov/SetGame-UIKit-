//
//  ViewController.swift
//  SetGame
//
//  Created by Dmitry Pyzhov on 31.08.2021.
//

import UIKit

class SetGameViewController: UIViewController {
    private var game = GameOfSet()
    
    private var dealDeckPosition: CGPoint {
        return CGPoint(x: view.bounds.midX, y: view.bounds.maxY)
    }
    
    private var cardViewsToDeal: [CardView] {
        return cardBoardView.cardViews.filter { $0.alpha == 0 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
    }
    
    // MARK: - Updates
    
    private func updateCardView(_ cardView: CardView, for card: Card) {
        cardView.numberInt = card.number.rawValue
        cardView.shapeInt = card.shape.rawValue
        cardView.shadingInt = card.shading.rawValue
        cardView.colorInt = card.color.rawValue
        
        cardView.outline = game.cardsSelected.contains(card) ? .selected : .notSelected
        
        if game.isSet != nil, game.cardsTryMatched.contains(card) {
            cardView.outline = game.isSet! ? .matched : .notMatched
        }
    }
    
    private func updateViewFromModel() {
        // TODO: Create new cards after match
        if game.cardsOnTable.count - cardBoardView.cardViews.count < 0 {
            cardBoardView.remove(cardViews: cardBoardView.cardViewsMatched)
        } else {
            cardBoardView.updateMatchedCards()
        }
        
        for index in game.cardsOnTable.indices {
            let card = game.cardsOnTable[index]
            
            if game.cardsOnTable.count - cardBoardView.cardViews.count > 0 {
                let cardView = CardView()
                cardBoardView.add(cardViews: [cardView])
            }
            updateCardView(cardBoardView.cardViews[index], for: card)
        }
        
        for cardView in cardBoardView.cardViews {
            if cardView.gestureRecognizers == nil {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCard(_:)))
                cardView.addGestureRecognizer(tapGesture)
            }
        }
        updateUIFromModel()
        playDealAnimation()
    }
    
    private func updateUIFromModel() {
        scoreLabel.text = "Score: \(game.score)"
        timeLabel.text = "Time: \(game.time)"
        timeLabel.isHidden = true
        hintsLabel.text = "Sets: \(game.setsCount)"
        getHintButton.isEnabled = game.setsCount > 0
        getHintButton.setTitleColor(getHintButton.isEnabled ? Color.activeButtonColor : Color.inactiveButtonColor, for: .normal)
        if let isSet = game.isSet, isSet {
            add3CardsButton.setTitle("Replace", for: .normal)
        } else {
            add3CardsButton.setTitle("+3 Cards", for: .normal)
        }
        add3CardsButton.setTitleColor(add3CardsButton.isEnabled ? Color.activeButtonColor : Color.inactiveButtonColor, for: .normal)
        add3CardsButton.isEnabled = !game.cards.isEmpty
        add3CardsButton.setTitleColor(game.cards.isEmpty ? Color.inactiveButtonColor : Color.activeButtonColor, for: .normal)
    }
    
    // MARK: - Animations
    
    private func playDealAnimation() {
        let startPoint = CGPoint(x: view.bounds.midX, y: view.bounds.maxY)
        for cardView in cardViewsToDeal.reversed() {
            cardView.dealAnimation(from: startPoint, delay: TimeInterval(cardViewsToDeal.count))
        }
    }
    
    private func playRearrangeAnimation() {
        
    }
    
    // MARK: - Outlets & Actions
    
    @IBOutlet weak var cardBoardView: CardBoardView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var hintsLabel: UILabel!
    
    @IBOutlet weak var getHintButton: UIButton!
    @IBAction func getHint(_ sender: UIButton) {
        // Hint не удаляет подсказанный набор, если он сматчился.
        updateViewFromModel()
        for cardView in cardBoardView.cardViews {
            cardView.isHinted = false
        }
        for index in game.getHint() {
            cardBoardView.cardViews[index].isHinted = true
        }
    }
    
    @IBOutlet weak var newGameButton: UIButton!
    @IBAction func newGame(_ sender: UIButton) {
        game = GameOfSet()
        cardBoardView.reset()
        updateViewFromModel()
    }
    
    @IBOutlet weak var add3CardsButton: UIButton!
    @IBAction func add3Cards(_ sender: UIButton) {
        guard !game.cards.isEmpty else { return }
        game.add3Cards()
        updateViewFromModel()
    }
    
    @IBAction func add3CardsWithTap(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case.ended:
            if game.isSet != nil, game.isSet! {
                game.add3Cards()
                updateViewFromModel()
            }
        default: break
        }
    }
    
    // MARK: - Gestures
    
    @objc func tapCard(_ gesture: UITapGestureRecognizer) {
        guard let gestureView = gesture.view else { return }
        if let cardView = gestureView as? CardView, let index = cardBoardView.cardViews.firstIndex(of: cardView) {
            // Check for Card Selections
            game.chooseCard(at: index)
            updateViewFromModel()
        }
    }
    
    @objc func add3CardsWithSwipe(_ gesture: UITapGestureRecognizer) {
        game.add3Cards()
        updateViewFromModel()
    }
    
    @objc func shuffleWithRotation(_ gesture: UIRotationGestureRecognizer) {
        game.shuffleCardsOnTable()
        updateViewFromModel()
    }
}

// MARK: - Constants

extension SetGameViewController {
    private struct Color {
        static let activeButtonColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        static let inactiveButtonColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
}
