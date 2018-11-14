//
//  ComboController.swift
//  ComboIntegra
//
//  Created by Miguel Estévez on 26/7/18.
//  Copyright © 2018 MES. All rights reserved.
//

import UIKit

public protocol ComboControllerDelegate: class {
    
    func numberOfRows(for comboController: ComboController) -> Int
    func comboController(_ comboController: ComboController, titleForRow row: Int) -> String
    func comboController(_ comboController: ComboController, heightForRow row: Int) -> Float
    func comboController(_ comboController: ComboController, willOpen animated: Bool)
    func comboController(_ comboController: ComboController, didOpen animated: Bool)
    func comboController(_ comboController: ComboController, willClose animated: Bool)
    func comboController(_ comboController: ComboController, didClose animated: Bool)
    func comboController(_ comboController: ComboController, didSelectRowAt rowIndex: Int)
}

public enum ComboControllerState {
    case opened, closed
}

public enum ComboControllerAnchorAligment: Int {
    case auto = 0, leading, trailing, center
}

public enum ComboControllerWidth {
    case auto
    case value(Float)
}

public class ComboController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Public properties
    public unowned var delegate: ComboControllerDelegate
    public unowned var anchorView: UIView
    
    public var tag = 0
    public var maxRows = 3
    public var cellHeight = 42.0
    public var cellBackgroundColor = UIColor.white
    public var cellTextColor = UIColor.black
    public var cellTextFont = UIFont.systemFont(ofSize: 14)
    public var cellLineColor = UIColor.clear
    public var showsScrollIndicator = true
    public var animationShowDuration = 0.25
    public var animationHideDuration = 0.25
    public var state = ComboControllerState.closed
    
    
    
    public var anchorAligment = ComboControllerAnchorAligment.auto {
        willSet {
            switch newValue {
            case .auto:
                contentViewTrailingConstraint.isActive = true
                contentViewLeadingConstraint.isActive = true
            case .center:
                contentViewTrailingConstraint.isActive = false
                contentViewLeadingConstraint.isActive = false
            case .leading:
                contentViewTrailingConstraint.isActive = false
                contentViewLeadingConstraint.isActive = true
            case .trailing:
                contentViewTrailingConstraint.isActive = true
                contentViewLeadingConstraint.isActive = false
            }
        }
    }
    
    public var customWidth: ComboControllerWidth = .auto {
        willSet {
            switch newValue {
            case .auto:
                anchorAligment = .auto
            case .value(let value):
                contentViewWidthConstraint.constant = CGFloat(value)
                if anchorAligment == .auto {
                    anchorAligment = .center
                }
            }
        }
    }
    
    // MARK: - Private properties
    
    private var anchorFrame: CGRect!
    private var tableView: UITableView!
    private var indexPath: IndexPath?
    private var contentViewHeightConstraint:   NSLayoutConstraint!
    private var contentViewWidthConstraint:    NSLayoutConstraint!
    private var contentViewTrailingConstraint: NSLayoutConstraint!
    private var contentViewLeadingConstraint:  NSLayoutConstraint!
    private var contentViewCenterConstraint:   NSLayoutConstraint!
    
    
    // MARK: - Initializers & view lifecycle
    
    public init(delegate: ComboControllerDelegate, anchorView: UIView) {
        
        self.delegate = delegate
        self.anchorView = anchorView
        
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        self.close(animated: false, completion: {
            self.dismiss(animated: false, completion: nil)
            self.delegate.comboController(self, didClose: false)
        })
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        open(animated: true)
    }
    
    // MARK: - PUBLIC INTERFACE
    
    public func showOn(_ viewController: UIViewController) {
        viewController.present(self, animated: false, completion: nil)
    }
    
    public func open(animated: Bool) {
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        delegate.comboController(self, willOpen: animated)
        
        let height = self.height(withMaxRows: maxRows)
        
        let openBlock = {
            self.contentViewHeightConstraint.constant = CGFloat(height)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        
        let completion = { (finished: Bool) -> Void in
            self.delegate.comboController(self, didOpen: animated)
        }
        
        if animated {
            UIView.animate(withDuration: animationShowDuration, delay: 0, options: .curveEaseOut, animations: openBlock, completion: completion)
        }
        else {
            openBlock()
            completion(true)
        }
    }
    
    public func close(animated: Bool, completion: @escaping () -> Void) {
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        delegate.comboController(self, willClose: animated)
        
        let closeBlock = {
            self.contentViewHeightConstraint.constant = CGFloat(0.0)
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: animationHideDuration, delay: 0, options: .curveEaseOut, animations: closeBlock, completion: { finished in completion() })
        }
        else {
            closeBlock()
            completion()
        }
    }
    
    public func deselectRow() {
        
        if let ip = indexPath {
            tableView.deselectRow(at: ip, animated: true)
        }
    }
    
    
    // MARK: - Table View Delegate & Data Source
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numberOfRows = delegate.numberOfRows(for: self)
        
        if numberOfRows == maxRows {
            tableView.isScrollEnabled = false
        }
        return numberOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "ComboCell")
        
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: "ComboCell")
            
            cell.backgroundColor = UIColor.clear
            cell.backgroundView?.backgroundColor = UIColor.clear
            
            let lineView = UIView()
            lineView.tag = 100
            lineView.backgroundColor = UIColor.clear
            lineView.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(lineView)
            
            let bindings = ["line": lineView]
            var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[line(1)]-0-|", options: .alignAllBottom, metrics: nil, views: bindings)
            cell.contentView.addConstraints(constraints)
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[line]-0-|", options: .alignAllBottom, metrics: nil, views: bindings)
            cell.contentView.addConstraints(constraints)
        }
        
        let lineView = cell.contentView.viewWithTag(100)
        lineView?.backgroundColor = cellLineColor
        
        cell.contentView.backgroundColor = cellBackgroundColor
        cell.textLabel?.textColor = cellTextColor
        cell.textLabel?.font = cellTextFont
        
        cell.textLabel?.text = delegate.comboController(self, titleForRow: indexPath.row)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.indexPath = indexPath
        
        delegate.comboController(self, didSelectRowAt: indexPath.row)
        
        let completion = {
            self.dismiss(animated: false, completion: nil)
            self.delegate.comboController(self, didClose: true)
        }
        close(animated: true, completion: completion)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let height = delegate.comboController(self, heightForRow: indexPath.row)
        return CGFloat(height)
    }
    
    // MARK: - Private methods
    
    private func setup() {
        
        view.backgroundColor = UIColor.clear
        
        // Back button
        
        let backButton = UIButton(type: .custom)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.backgroundColor = UIColor.clear
        view.addSubview(backButton)
        
        var bindings: [String: Any] = ["backButton": backButton]
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[backButton]-0-|", options: .alignAllLeft, metrics: nil, views: bindings)
        view.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[backButton]-0-|", options: .alignAllLeft, metrics: nil, views: bindings)
        view.addConstraints(constraints)
        
        // Anchor view
        
        let anchorView = UIView()
        anchorView.translatesAutoresizingMaskIntoConstraints = false
        anchorView.isUserInteractionEnabled = false
        anchorView.backgroundColor = UIColor.clear
        view.addSubview(anchorView)
        
        bindings = ["anchorView": anchorView]
        
        self.anchorFrame = self.anchorView.superview?.convert(self.anchorView.frame, to: nil)
        
        var visualFormat = "H:|-\(anchorFrame.origin.x)-[anchorView(\(anchorFrame.size.width))]"
        constraints = NSLayoutConstraint.constraints(withVisualFormat: visualFormat, options: .alignAllLeft, metrics: nil, views: bindings)
        view.addConstraints(constraints)
        visualFormat = "V:|-\(anchorFrame.origin.y)-[anchorView(\(anchorFrame.size.height))]"
        constraints = NSLayoutConstraint.constraints(withVisualFormat: visualFormat, options: .alignAllLeft, metrics: nil, views: bindings)
        view.addConstraints(constraints)
        
        anchorView.layoutIfNeeded()
        
        // Content View
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.white
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowRadius = 1.5
        contentView.layer.shadowOpacity = 0.3
        view.addSubview(contentView)
        
        contentViewLeadingConstraint = NSLayoutConstraint( item: contentView, attribute: .leading, relatedBy: .equal,
                                                           toItem: anchorView, attribute: .leading, multiplier: 1.0, constant: 0.0)
        view.addConstraint(contentViewLeadingConstraint)
        
        contentViewTrailingConstraint = NSLayoutConstraint( item: contentView, attribute: .trailing, relatedBy: .equal,
                                                            toItem: anchorView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        view.addConstraint(contentViewTrailingConstraint)
        
        let constraint = NSLayoutConstraint( item: contentView, attribute: .top, relatedBy: .equal,
                                             toItem: anchorView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        view.addConstraint(constraint)
        
        contentViewHeightConstraint = NSLayoutConstraint( item: contentView, attribute: .height, relatedBy: .equal,
                                                          toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        contentView.addConstraint(contentViewHeightConstraint)
        
        contentViewWidthConstraint = NSLayoutConstraint( item: contentView, attribute: .width, relatedBy: .equal,
                                                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.anchorView.frame.size.width)
        contentViewWidthConstraint.priority = .defaultHigh
        contentView.addConstraint(contentViewWidthConstraint)
        
        contentViewCenterConstraint = NSLayoutConstraint( item: contentView, attribute: .centerX, relatedBy: .equal,
                                                          toItem: anchorView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        contentViewCenterConstraint.priority = .defaultHigh
        view.addConstraint(contentViewCenterConstraint)
        
        // Table View
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = showsScrollIndicator
        tableView.rowHeight = CGFloat(cellHeight)
        
        contentView.addSubview(tableView)
        
        bindings = ["tableView": tableView]
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: .alignAllLeft, metrics: nil, views: bindings)
        contentView.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tableView]-0-|", options: .alignAllLeft, metrics: nil, views: bindings)
        contentView.addConstraints(constraints)
    }
    
    private func height(withMaxRows maxRows: Int) -> Float {
        
        let rows = delegate.numberOfRows(for: self)
        var total = Float(0.0)
        
        for i in 0 ..< maxRows {
            
            if i >= rows { break }
            
            total += delegate.comboController(self, heightForRow: i)
        }
        return total
    }
    
    @objc private func backButtonTapped(_ sender: UIButton) {
        
        let animated = true
        
        let completion = {
            self.dismiss(animated: false, completion: nil)
            self.delegate.comboController(self, didClose: animated)
        }
        close(animated: animated, completion: completion)
    }
    
}
