//
//  CardBoardView.swift
//  SetGame
//
//  Created by Dmitry Pyzhov on 19.10.2021.
//

import UIKit

class CardBoardView: UIView {
    
    private(set) var cardViews = [CardView]()
    
    var cardViewsMatched: [CardView] {
        cardViews.filter { $0.outline == .matched }
    }
    
    func add(cardViews: [CardView]) {
        cardViews.forEach { cardView in
            self.cardViews.append(cardView)
            addSubview(cardView)
        }
        layoutIfNeeded()
    }
    
    func remove(cardViews: [CardView]) {
        cardViews.forEach {
            $0.removeFromSuperview()
        }
        self.cardViews.remove(elements: cardViews)
        layoutIfNeeded()
    }
    
    func reset() {
        cardViews.forEach {
            self.cardViews.remove(elements: [$0])
            $0.removeFromSuperview()
        }
        layoutIfNeeded()
    }
    
    private func replaceWithNewCard(cardView: CardView) {
        if let index = cardViews.firstIndex(of: cardView) {
            cardViews[index].removeFromSuperview()
            cardViews[index] = CardView()
            addSubview(cardViews[index])
        }
    }
    
    func updateMatchedCards() {
        cardViewsMatched.forEach { cardView in
            replaceWithNewCard(cardView: cardView)
        }
    }
    
    private func updateView() {
        super.layoutSubviews()
        
        var grid = Grid(layout: .aspectRatio(Constant.cardAspectRatio), frame: self.bounds)
        grid.cellCount = cardViews.count
        
        for index in cardViews.indices {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 0.1,
                options: [.curveEaseOut],
                animations: {
                    self.cardViews[index].frame = grid[index]!.insetBy(dx: Constant.cardInset, dy: Constant.cardInset)

                }
            )
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
}

// MARK: - Constants

extension CardBoardView {
    private struct Constant {
        static let cardAspectRatio: CGFloat = 0.7
        static let cardInset: CGFloat = 2.5
    }
}
