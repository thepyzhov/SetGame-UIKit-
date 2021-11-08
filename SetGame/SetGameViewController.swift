//
//  ViewController.swift
//  SetGame
//
//  Created by Dmitry Pyzhov on 31.08.2021.
//

import UIKit

class SetGameViewController: UIViewController {
    private var game = GameOfSet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
    }
    
    private func createNewCardView(for card: Card) -> CardView {
        let cardView = CardView()
        cardView.numberInt = card.number.rawValue
        cardView.shapeInt = card.shape.rawValue
        cardView.shadingInt = card.shading.rawValue
        cardView.colorInt = card.color.rawValue
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCard))
        //tapGesture.delegate = self
        cardView.addGestureRecognizer(tapGesture)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(add3CardsWithSwipe))
        swipeGesture.direction = [.left, .right]
        cardView.addGestureRecognizer(swipeGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(shuffleWithRotation))
        cardView.addGestureRecognizer(rotationGesture)
        
        return cardView
    }
    
    private func updateViewFromModel() {
        var cardViews = [CardView]()
        for card in game.cardsOnTable {
            let cardView = createNewCardView(for: card)
            cardView.outline = game.cardsSelected.contains(card) ? .selected : .notSelected
            
            if game.isSet != nil, game.cardsTryMatched.contains(card) {
                cardView.outline = game.isSet! ? .matched : .notMatched
            }
            cardViews.append(cardView)
        }
        cardBoardView.cardViews = cardViews
        
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
        //add3CardsButton.isEnabled = game.cardsOnTable.count < cardButtons.count && !game.cards.isEmpty || game.isSet != nil && game.isSet! && !game.cards.isEmpty
        add3CardsButton.setTitleColor(add3CardsButton.isEnabled ? Color.activeButtonColor : Color.inactiveButtonColor, for: .normal)
    }
    
    @IBOutlet weak var cardBoardView: CardBoardView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var hintsLabel: UILabel!
    
    @IBOutlet weak var getHintButton: UIButton!
    @IBAction func getHint(_ sender: UIButton) {
        updateViewFromModel()
        for index in game.getHint() {
            cardBoardView.cardViews[index].isHinted = true
        }
    }
    
    @IBOutlet weak var newGameButton: UIButton!
    @IBAction func newGame(_ sender: UIButton) {
        game = GameOfSet()
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
