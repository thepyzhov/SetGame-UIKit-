//
//  CardView.swift
//  SetGame
//
//  Created by Dmitry Pyzhov on 06.10.2021.
//

import UIKit

class CardView: UIView {
    var numberInt = 0 { didSet { number = numberInt } }
    var shapeInt = 0 {
        didSet {
            switch shapeInt {
            case 0: shape = .diamond
            case 1: shape = .squiggle
            case 2: shape = .roundedRect
            default: break
            }
        }
    }
    var shadingInt = 0 {
        didSet {
            switch shadingInt {
            case 0: shading = .empty
            case 1: shading = .striped
            case 2: shading = .filled
            default: break
            }
        }
    }
    var colorInt = 0 {
        didSet {
            switch colorInt {
            case 0: color = Color.red
            case 1: color = Color.green
            case 2: color = Color.blue
            default: break
            }
        }
    }
    var outline: OutlineType = .notSelected { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var isHinted = false { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    enum OutlineType {
        case selected
        case notSelected
        case matched
        case notMatched
    }
    
    var isSelected = false { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var isMatched: Bool? = nil { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    private var number = 0 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    private var shape = Shape.diamond { didSet { setNeedsDisplay(); setNeedsLayout() } }
    private var shading = Shading.empty { didSet { setNeedsDisplay(); setNeedsLayout() } }
    private var color = Color.red { didSet { setNeedsDisplay(); setNeedsLayout() } }
    private var borderColor = Color.transparent
    
    private enum Shape: Int {
        case diamond
        case squiggle
        case roundedRect
    }
    
    private enum Shading: Int {
        case empty
        case striped
        case filled
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
        backgroundColor = Color.transparent
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawSelectionBorder()
        drawRoundedRectBackground()
        drawShape()
    }
    
    
    
    func drawSelectionBorder() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        let selectionRect = UIBezierPath(roundedRect: bounds, cornerRadius: Constant.cardRoundedRectCornerRadius)
        selectionRect.addClip()
        
        switch outline {
        case .selected: Color.selected.setFill()
        case .notSelected: Color.transparent.setFill()
        case .matched: Color.matched.setFill()
        case .notMatched: Color.notMatched.setFill()
        }
        
        selectionRect.fill()
        context.restoreGState()
    }
    
    private func drawRoundedRectBackground() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        let boundsWithSelection = bounds.insetBy(dx: Constant.cardSelectionBorderLineWidth, dy: Constant.cardSelectionBorderLineWidth)
        let roundedRect = UIBezierPath(roundedRect: boundsWithSelection, cornerRadius: Constant.cardRoundedRectCornerRadius)
        roundedRect.addClip()
        let roundRectColor = isHinted ? Color.hint : Color.cardRoundedRect
        roundRectColor.setFill()
        roundedRect.fill()
        context.restoreGState()
    }
    
    private func drawShape() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        let innerBounds = bounds.insetBy(dx: bounds.size.width * (1 - Constant.shapeScale) / 2,
                                         dy: (bounds.size.height + (bounds.size.width * (1 - Constant.shapeScale) / 2)) / 2 - bounds.size.width / 4)
        let paths = makePaths(in: innerBounds)
        for path in paths {
            color.setStroke()
            path.lineWidth = Constant.spaheLineWidth
            
            switch shading {
            case .empty: break
            case .striped: stripeShape(path: path, in: bounds)
            case .filled: fillShape(path: path, in: bounds)
            }
            
            path.close()
            path.stroke()
        }
        context.restoreGState()
    }
    
    private func stripeShape(path: UIBezierPath, in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        path.addClip()
        stripeRect(rect)
        context.restoreGState()
    }
    
    private func stripeRect(_ rect: CGRect) {
        let stripe = UIBezierPath()
        stripe.lineWidth = Constant.stripeLineWidth
        stripe.move(to: CGPoint(x: rect.minX, y: rect.minY))
        stripe.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        let stripesCount = Int(rect.width / Constant.stripeStep)
        for _ in 1...stripesCount {
            let translation = CGAffineTransform(translationX: Constant.stripeStep, y: 0)
            stripe.apply(translation)
            stripe.stroke()
        }
    }
    
    private func fillShape(path: UIBezierPath, in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        path.addClip()
        color.setFill()
        path.fill()
        context.restoreGState()
    }
    
    private func makePaths(in rect: CGRect) -> [UIBezierPath] {
        var paths = [UIBezierPath]()
        var shapeDrawer: ((CGRect) -> UIBezierPath)
        
        switch shape {
        case .diamond: shapeDrawer = getPathForDiamond
        case .squiggle: shapeDrawer = getPathForSquiggle
        case .roundedRect: shapeDrawer = getPathForRoundedRect
        }
        
        for _ in 0...numberInt {
            paths.append(shapeDrawer(rect))
        }
        
        switch number {
        case 0:
            paths[0].apply(CGAffineTransform(translationX: 0, y: 0))
        case 1:
            paths[0].apply(CGAffineTransform(translationX: 0, y: -rect.height / 2 * Constant.shapeSpacing))
            paths[1].apply(CGAffineTransform(translationX: 0, y: +rect.height / 2 * Constant.shapeSpacing))
        case 2:
            paths[0].apply(CGAffineTransform(translationX: 0, y: -rect.height * Constant.shapeSpacing))
            paths[1].apply(CGAffineTransform(translationX: 0, y: 0))
            paths[2].apply(CGAffineTransform(translationX: 0, y: +rect.height * Constant.shapeSpacing))
        default:
            print("CardView switch(number) is too big: \(number)")
        }
        
        return paths
    }
}

// MARK: - Constants

extension CardView {
    private struct Constant {
        static let cardRoundedRectCornerRadius: CGFloat = 8.0
        static let cardSelectionBorderLineWidth: CGFloat = 3.5
        // scale = 0.3, spacing = 1.5
        // scale = 0.45, spacing = 1.4
        static let shapeScale: CGFloat = 0.45
        static let shapeSpacing: CGFloat = 1.4
        static let spaheLineWidth: CGFloat = 0.8
        
        static let stripeLineWidth: CGFloat = spaheLineWidth * 0.5
        static let stripedShapeFill: CGFloat = 0.15
        static let stripeStep = Constant.stripeLineWidth * (1 / Constant.stripedShapeFill)
    }
    
    private struct Color {
        static let red = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        static let green = #colorLiteral(red: 0.1837899051, green: 0.7259903725, blue: 0.06666154582, alpha: 1)
        static let blue = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        
        static let transparent = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        static let cardRoundedRect = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let selected = #colorLiteral(red: 0, green: 0.7222121358, blue: 0.9383115172, alpha: 0.8470588235)
        static let deselected = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        static let matched = #colorLiteral(red: 0.2040645805, green: 0.8897407091, blue: 0.1905413759, alpha: 1)
        static let notMatched = #colorLiteral(red: 0.8883991687, green: 0.2503136889, blue: 0.3165596953, alpha: 1)
        static let hint = #colorLiteral(red: 0.8962020384, green: 0.8602213921, blue: 0.9764705896, alpha: 1)
    }
}

// MARK: - Shape Paths

extension CardView {
    private func getPathForDiamond(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.close()
        
        return path
    }
    
    private func getPathForSquiggle(in rect: CGRect) -> UIBezierPath {
        let minX = rect.minX
        let midX = rect.midX
        let maxX = rect.maxX
        let minY = rect.minY
        let midY = rect.midY
        let maxY = rect.maxY
        let width = rect.width
        let height = rect.height
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: maxX - width / 8 * 0.55, y: minY + height * 0.05))
        path.addCurve(to: CGPoint(x: midX + width / 4 * 0.75, y: minY + height / 4 * 0.95),
                      controlPoint1: CGPoint(x: maxX - width / 4 * 0.55, y: minY - height / 4 * 0.03),
                      controlPoint2: CGPoint(x: maxX - width / 4 * 0.7, y: minY + height / 4 * 0.75))
        path.addCurve(to: CGPoint(x: minX + width / 4 * 0.9, y: minY + height / 4 * 0.1),
                      controlPoint1: CGPoint(x: midX, y: midY - height / 4 * 0.9),
                      controlPoint2: CGPoint(x: midX - width / 8 * 0.25, y: minY - height / 4 * 0.1))
        path.addCurve(to: CGPoint(x: minX + width / 8 * 0.6, y: maxY - height / 4 * 0.15),
                      controlPoint1: CGPoint(x: minX - width / 8 * 0.2, y: minY + height / 4 * 0.4),
                      controlPoint2: CGPoint(x: minX - width / 8 * 0.15, y: maxY - height / 4 * 0.25))
        path.addCurve(to: CGPoint(x: midX - width / 8, y: maxY - height / 4 * 0.9),
                      controlPoint1: CGPoint(x: minX + width / 4 * 0.7, y: maxY + height / 4 * 0.1),
                      controlPoint2: CGPoint(x: minX + width / 4 * 0.8, y: maxY - height / 4 * 0.75))
        path.addCurve(to: CGPoint(x: maxX - width / 4 * 0.8, y: maxY - height / 4 * 0.55),
                      controlPoint1: CGPoint(x: midX + width / 8 * 0.35, y: maxY - height / 4),
                      controlPoint2: CGPoint(x: midX + width / 8 * 0.1, y: maxY + height / 4 * 0.2))
        path.addCurve(to: CGPoint(x: maxX - width / 8 * 0.55, y: minY + height * 0.05),
                      controlPoint1: CGPoint(x: maxX + width / 8 * 0.5, y: midY + height / 4 * 0.7),
                      controlPoint2: CGPoint(x: maxX + width / 8 * 0.05, y: minY + height / 4 * 0.35))
        return path
    }
    
    private func getPathForRoundedRect(in rect: CGRect) -> UIBezierPath {
        let roundedRect = UIBezierPath()
        let radius = rect.height / 2
        roundedRect.addArc(withCenter: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                    radius: radius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi * 3 / 2, clockwise: true)
        roundedRect.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        roundedRect.addArc(withCenter: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                    radius: radius, startAngle: CGFloat.pi * 3 / 2, endAngle: CGFloat.pi / 2, clockwise: true)
        roundedRect.close()
        return roundedRect
    }
}
