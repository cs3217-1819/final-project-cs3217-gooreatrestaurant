//
//  ViewController.swift
//  slime
//
//  Created by Gabriel Tan on 18/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

// Base VC class to inherit for all VCs used in the view hierarchy.
class ViewController<View: UIView>: ViewControllerProtocol {
    // The base view of the controller.
    internal var view: View
    
    // The context of the view controller.
    internal var context: Context!
    
    // A convenient variable to get the router from the context.
    internal var router: Router {
        return context.router
    }
    
    // This array stores all child controllers that need not be configured
    // a second time. Storing the controllers ensures that callbacks are
    // fired off.
    private var controllers: [AnyObject] = []

    // Use a specified context object.
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

    // configureSubviews should be overridden to do setup.
    func configureSubviews() {

    }

    // Convenient method to include a button at the center top of the
    // view controller's view which routes to a given route.
    internal func configureUpButton(to route: Route) {
        let upButton = UIView.initFromNib("UpButton")
        let control = ButtonController(using: upButton)
        control.sound = "back"
        control.onTap {
            self.context.routeTo(route)
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

    // Creates and shows an up button which routes to the previous route.
    internal func configureUpButtonAsPrevious() {
        guard let previousRoute = router.previousRoute else {
            return
        }
        configureUpButton(to: previousRoute)
    }

    // Convenience function to store an array of controller references.
    internal func rememberAll<ControllerType: Controller>(_ controllers: [ControllerType]) {
        self.controllers.append(contentsOf: controllers)
    }

    // Used for storing references to controllers
    internal func remember<ControllerType: Controller>(_ controller: ControllerType) {
        controllers.append(controller)
    }

    func getView() -> UIView {
        return view
    }

    // All children should call this, even if overridden, so memory is deallocated
    // properly.
    func onDisappear() {
        view.removeFromSuperview()
        controllers = []
    }

    deinit {
        Logger.it.info("VC Deinit")
    }
}
