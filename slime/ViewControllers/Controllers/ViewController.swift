//
//  ViewController.swift
//  slime
//
//  Created by Gabriel Tan on 18/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class ViewController<View: UIView>: ViewControllerProtocol {
    internal var view: View
    internal var context: Context!
    internal var router: Router {
        return context.router
    }
    private var controllers: [AnyObject] = []
    
    func use(context: Context) {
        self.context = context
    }
    
    required init(with view: UIView) {
        guard let trueView = view as? View else {
            fatalError("Nib class is wrong")
        }
        self.view = trueView
        super.init()
    }
    
    func configureSubviews() {
        
    }
    
    internal func configureUpButton(to route: Route) {
        let upButton = UIView.initFromNib("UpButton")
        let control = ButtonController(using: upButton)
        control.onTap {
            self.router.routeTo(route)
        }
        
        view.addSubview(upButton)
        upButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        remember(control)
        view.layoutIfNeeded()
    }
    
    internal func configureUpButtonAsPrevious() {
        guard let previousRoute = router.previousRoute else {
            return
        }
        configureUpButton(to: previousRoute)
    }
    
    internal func rememberAll(_ controllers: [AnyObject]) {
        self.controllers.append(contentsOf: controllers)
    }
    
    // Used for storing references to controllers
    internal func remember(_ controller: AnyObject) {
        controllers.append(controller)
    }
    
    func getView() -> UIView {
        return view
    }
}
