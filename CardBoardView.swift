//
//  CardBoardView.swift
//  SetGame
//
//  Created by Dmitry Pyzhov on 19.10.2021.
//

import UIKit

class CardBoardView: UIView {
    
    var cardViews = [CardView]() {
        willSet { removeSubviews() }
        didSet { addSubviews(); setNeedsLayout() }
    }
    
    private func addSubviews() {
        for cardView in cardViews {
            addSubview(cardView)
        }
    }
    
    private func removeSubviews() {
        for cardView in cardViews {
            cardView.removeFromSuperview()
        }
    }
    
    private func updateView() {
        super.layoutSubviews()
        
        var grid = Grid(layout: .aspectRatio(Constant.cardAspectRatio), frame: self.bounds)
        grid.cellCount = cardViews.count
        
        for index in cardViews.indices {
            cardViews[index].frame = grid[index]!.insetBy(dx: Constant.cardInset, dy: Constant.cardInset)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }

    override func draw(_ rect: CGRect) {
        // Drawing code
    }
}

// MARK: - Constants

extension CardBoardView {
    private struct Constant {
        static let cardAspectRatio: CGFloat = 0.7
        static let cardInset: CGFloat = 2.5
    }
}
