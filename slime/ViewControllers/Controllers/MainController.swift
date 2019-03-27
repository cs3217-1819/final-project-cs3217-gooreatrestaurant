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
    private var bgControl: ScrollingBackgroundViewController?
    
    override func viewWillLayoutSubviews() {
        if bgControl == nil {
            // TODO: more robust checking, deinit when rotate
            bgControl = ScrollingBackgroundViewController(with: view)
            bgControl?.configure()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = Context(using: self)
        setupView()
    }
    
    // Perform segue called from context
    func performSegue(from fromVC: ViewControllerProtocol,
                      to toVC: ViewControllerProtocol,
                      coordsDiff: CGPoint) {
        adjustBackground()
        let screenSize = CGPoint(x: view.frame.width, y: view.frame.height)
        // points based on scale of screen size
        let diff = coordsDiff .* screenSize
        
        let toView = toVC.getView()
        toView.frame = CGRect(x: diff.x, y: diff.y, width: view.bounds.width, height: view.bounds.height)
        toView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toVC.use(context: context)
        toVC.configureSubviews()
        
        view.addSubview(toView)
        let fromVCFrame = fromVC.getView().frame
        UIView.animate(withDuration: 1.0, animations: {
            fromVC.getView().frame = fromVCFrame.offsetBy(dx: -diff.x, dy: -diff.y)
            toView.frame = toView.frame.offsetBy(dx: -diff.x, dy: -diff.y)
        }, completion: { finished in
            fromVC.onDisappear()
        })
    }
    
    private func setupView() {
        adjustBackground()
        let vc = router.currentViewController
        vc.use(context: context)
        vc.configureSubviews()
        vc.getView().frame = view.bounds
        vc.getView().autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(vc.getView())
    }
    
    private func adjustBackground() {
        if router.currentRoute == .TitleScreen {
            bgControl?.toAlpha(1.0)
            bgControl?.transitionTo("background")
        } else {
            bgControl?.toAlpha(0.5)
            bgControl?.transitionTo("background-1")
        }
    }
}
