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
    @IBOutlet var underlyingView: UIView!
    private let disposeBag = DisposeBag()
    private var context: Context!
    private var router: Router {
        return context.router
    }
    private var bgControl: ScrollingBackgroundViewController?
    fileprivate var isSetup: Bool = false

    override func viewWillLayoutSubviews() {
        if bgControl == nil {
            // TODO: more robust checking
            bgControl = ScrollingBackgroundViewController(with: underlyingView)
            bgControl?.configure()
        }

        if !isSetup {
            setupView()
            isSetup = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        context = Context(using: self)
        setupHideKeyboardOnTap()
    }

    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }

    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }

    // Perform segue called from context
    func performSegue(from fromVC: ViewControllerProtocol,
                      to toVC: ViewControllerProtocol,
                      coordsDiff: CGPoint) {
        adjustBackground()
        let screenSize = CGPoint(x: underlyingView.frame.width, y: underlyingView.frame.height)
        // points based on scale of screen size
        let diff = coordsDiff .* screenSize

        let toView = toVC.getView()
        toView.frame = CGRect(x: diff.x, y: diff.y, width: underlyingView.bounds.width, height: underlyingView.bounds.height)
        toView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toVC.use(context: context)
        toVC.configureSubviews()

        underlyingView.addSubview(toView)
        let fromVCFrame = fromVC.getView().frame
        UIView.animate(withDuration: 0.210, animations: {
            fromVC.getView().frame = fromVCFrame.offsetBy(dx: -diff.x, dy: -diff.y)
            toView.frame = toView.frame.offsetBy(dx: -diff.x, dy: -diff.y)
        })

        Timer.scheduledTimer(withTimeInterval: 0.210, repeats: false, block: { _ in
            fromVC.onDisappear()
        })
    }

    private func setupView() {
        adjustBackground()
        let vc = router.currentViewController
        vc.use(context: context)
        vc.configureSubviews()
        vc.getView().frame = underlyingView.bounds
        vc.getView().autoresizingMask = [.flexibleWidth, .flexibleHeight]
        underlyingView.addSubview(vc.getView())
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMultiplayerGame" {
            let destination = segue.destination as! GameViewController
            let currentRoute = self.router.currentViewController as! MultiplayerLobbyViewController

            guard let room = currentRoute.currentRoom else {
                print("pew pew")
                return
            }
            
            destination.isMultiplayer = true
            destination.currentMap = room.map
            destination.multiplayerGameId = room.id
        }
        
        if segue.identifier == "toMultiplayerGame" {
            // let destination = segue.destination as! GameViewController
            // let currentRoute = self.router.currentViewController as! LevelSelectViewController
            
            
        }
    }
}
