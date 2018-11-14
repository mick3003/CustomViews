//
//  Switch.swift
//  ComboIntegra
//
//  Created by Miguel Estévez on 1/8/18.
//  Copyright © 2018 MES. All rights reserved.
//

import UIKit

@IBDesignable
open class Switch: UIControl {
    
    static let defaultWidth: CGFloat = 40
    static let defaultHeight: CGFloat = 22
    static let animationDuration: Float = 0.25
    
    static let defaultOnTintColor = UIColor(displayP3Red: 128.0/255.0, green: 218.0/255.0, blue: 117.0/255.0, alpha: 1.0)
    static let defaultOffTintColor = UIColor.lightGray
    static let defaultThumbTintColor = UIColor.white
    
    var animated = false
    
    @IBInspectable
    public var on: Bool = false {
        didSet {
            toogle(animated: animated)
            animated = false
        }
    }
    
    public var isOn: Bool {
        get {
            return on
        }
    }
    
    @IBInspectable
    public var onColor: UIColor = Switch.defaultOnTintColor {
        didSet {
            if on {
                backgroundView.backgroundColor = onColor
            }
        }
    }
    
    @IBInspectable
    public var offColor: UIColor = Switch.defaultOffTintColor {
        didSet {
            if !on {
                backgroundView.backgroundColor = offColor
            }
        }
    }
    
    public var thumbColor = Switch.defaultThumbTintColor {
        didSet {
            thumbOnColor = thumbColor
            thumbOffColor = thumbColor
            toogleView.backgroundColor = thumbColor
        }
    }
    
    @IBInspectable
    public var thumbOnColor: UIColor = Switch.defaultThumbTintColor {
        didSet {
            if on {
                toogleView.backgroundColor = thumbOnColor
            }
        }
    }
    
    @IBInspectable
    public var thumbOffColor: UIColor = Switch.defaultThumbTintColor {
        didSet {
            if !on {
                toogleView.backgroundColor = thumbOffColor
            }
        }
    }
    
    public func set(on: Bool, animated: Bool) {
        self.animated = animated
        self.on = on
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        
        layoutIfNeeded()
        self.backgroundColor = UIColor.clear
        
        backgroundView.layer.cornerRadius = backgroundView.frame.height / 2.0
        toogleView.layer.cornerRadius = toogleView.frame.height / 2.0
        
        var constraint = NSLayoutConstraint( item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1.0, constant: Switch.defaultWidth)
        addConstraint(constraint)
        
        constraint = NSLayoutConstraint( item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1.0, constant: Switch.defaultHeight)
        addConstraint(constraint)
        setNeedsDisplay()
    }
    
    open override func awakeFromNib() {
        
        super.awakeFromNib()
        
        offColor = UIColor(white: 0.8, alpha: 1.0)
        
        // Setup here other colors ????
    }
    
    // Private interface
    var backgroundView = UIView()
    var toogleView = UIView()
    var leftToogleConstraint: NSLayoutConstraint!
    var rightToogleConstraint: NSLayoutConstraint!
    
    private func setup() {
        
        var constraint = NSLayoutConstraint( item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1.0, constant: Switch.defaultWidth)
        addConstraint(constraint)
        
        constraint = NSLayoutConstraint( item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1.0, constant: Switch.defaultHeight)
        addConstraint(constraint)
        
        // HDVIEW //
        backgroundColor = UIColor.clear
        clipsToBounds = false
        
        // BACKGROUND //
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.layer.backgroundColor = offColor.cgColor
        backgroundView.clipsToBounds = true
        addSubview(backgroundView)
        
        let horizontalMargin = 2.0
        
        var bindings = ["backgroundView": backgroundView]
        let visualFormat = "H:|-\(horizontalMargin)-[backgroundView]-\(horizontalMargin)-|"
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: visualFormat, options: .alignAllLeft, metrics: nil, views: bindings)
        addConstraints(constraints)
        
        constraint = NSLayoutConstraint( item: backgroundView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1.0, constant: 0.0)
        addConstraint(constraint)
        
        constraint = NSLayoutConstraint( item: backgroundView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height,
                                         multiplier: 0.65, constant: 0.0)
        addConstraint(constraint)
        
        // TOOGLE VIEW //
        toogleView.translatesAutoresizingMaskIntoConstraints = false
        toogleView.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        toogleView.clipsToBounds = true
        toogleView.layer.masksToBounds = false
        toogleView.layer.shadowOffset = CGSize(width: 0, height: 1)
        toogleView.layer.shadowRadius = 1.5
        toogleView.layer.shadowOpacity = 0.3
        addSubview(toogleView)
        
        constraint = NSLayoutConstraint( item: toogleView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height,
                                         multiplier: 1.0, constant: 0.0)
        addConstraint(constraint)
        
        constraint = NSLayoutConstraint( item: toogleView, attribute: .width, relatedBy: .equal, toItem: toogleView, attribute: .height,
                                         multiplier: 1.0, constant: 0.0)
        // check this!!!
        toogleView.addConstraint(constraint)
        
        constraint = NSLayoutConstraint( item: toogleView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1.0, constant: 0.0)
        addConstraint(constraint)
        
        leftToogleConstraint = NSLayoutConstraint( item: toogleView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading,
                                                   multiplier: 1.0, constant: 0.0)
        addConstraint(leftToogleConstraint)
        
        rightToogleConstraint = NSLayoutConstraint( item: toogleView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing,
                                                    multiplier: 1.0, constant: 0.0)
        
        // BUTTON //
        let button = UIButton(type: .custom)
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(button)
        
        bindings = ["button": button]
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[button]-0-|", options: .alignAllLeft, metrics: nil, views: bindings)
        addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[button]-0-|", options: .alignAllLeft, metrics: nil, views: bindings)
        addConstraints(constraints)
        
        layoutIfNeeded()
        backgroundView.layer.cornerRadius = backgroundView.frame.size.height / 2.0
        toogleView.layer.cornerRadius = toogleView.frame.size.height / 2.0
    }
    
    private func toogle(animated: Bool) {
        
        removeConstraints([leftToogleConstraint, rightToogleConstraint])
        
        var newColor: UIColor!
        var newThumbColor: UIColor!
        
        if on {
            addConstraint(rightToogleConstraint)
            newColor = onColor
            newThumbColor = thumbOnColor
        }
        else {
            addConstraint(leftToogleConstraint)
            newColor = offColor
            newThumbColor = thumbOffColor
        }
        
        let animations = {
            self.backgroundView.layer.backgroundColor = newColor.cgColor
            self.toogleView.layer.backgroundColor = newThumbColor.cgColor
            self.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: TimeInterval(Switch.animationDuration), delay: 0.0, options: .curveEaseOut, animations: animations, completion: nil)
        }
        else {
            animations()
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        animated = true
        on = !on
        sendActions(for: .valueChanged)
    }
}
