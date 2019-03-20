//
//  MainController.swift
//  slime
//
//  Created by Gabriel Tan on 15/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class MainController: UIViewController {
    private let disposeBag = DisposeBag()
    private var context: Context!
    private var router: Router {
        return context.router
    }
    private var routerVC: ViewControllerProtocol?
    private var bgControl: ScrollingBackgroundViewController?
    
    override func viewWillLayoutSubviews() {
        if bgControl == nil {
            // TODO: more robust checking, deinit when rotate
            bgControl = ScrollingBackgroundViewController(with: view)
        }
        
        if routerVC == nil {
            setupView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = Context(using: self)
        setupRouter()
    }
    
    func setupView() {
        if router.currentRoute == .TitleScreen {
            bgControl?.toAlpha(1.0)
        } else {
            bgControl?.toAlpha(0.5)
        }
        guard let vc = routerVC else {
            // No existing VC, just place view on screen
            routerVC = router.getCurrentViewController()
            routerVC?.configureSubviews()
            routerVC?.use(context: context)
            guard let routerView = routerVC?.getView() else {
                return
            }
            routerView.frame = view.bounds
            routerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(routerView)
            return
        }
        // Do transition based on coordinates
        guard let previousRoute = router.previousRoute else {
            return
        }
        // TODO: refactor this trash
        let vc1coords = previousRoute.coordinates
        let vc2coords = router.currentRoute.coordinates
        
        let screenSize = CGPoint(x: view.frame.width, y: view.frame.height)
        // points based on scale of screen size
        let truev1 = vc1coords .* screenSize
        let truev2 = vc2coords .* screenSize
        let diff = truev2 - truev1
        
        let secondVC = router.getCurrentViewController()
        let toView = secondVC.getView()
        toView.frame = toView.frame.offsetBy(dx: diff.x, dy: diff.y)
        toView.frame = CGRect(x: diff.x, y: diff.y, width: view.bounds.width, height: view.bounds.height)
        toView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        print("before context")
        secondVC.use(context: context)
        print("after context")
        secondVC.configureSubviews()
        
        
        view.addSubview(toView)
        routerVC = secondVC
        UIView.animate(withDuration: 1.0, animations: {
            vc.getView().frame = vc.getView().frame.offsetBy(dx: -diff.x, dy: -diff.y)
            toView.frame = toView.frame.offsetBy(dx: -diff.x, dy: -diff.y)
        }, completion: { finished in
            vc.onDisappear()
        })
    }
    
    func setupRouter() {
        router.transitionHandler.subscribe { route in
            DispatchQueue.main.async {
                self.setupView()
            }
        }
    }
    
    func segueToGame() {
        
    }
}
