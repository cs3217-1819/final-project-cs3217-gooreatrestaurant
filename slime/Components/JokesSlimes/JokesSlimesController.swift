//
//  JokesSlimesController.swift
//  slime
//
//  Created by Gabriel Tan on 10/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import SnapKit
import RxSwift

class JokesSlimesController: Controller {
    let view: JokesSlimesView
    // 0 - 5, corresponds to placing in queue
    private var dialogBoxes: [DialogBoxController] = []
    private var jokes: [Joke] = []
    private var jokeIndex = 0
    private var timer: Timer?
    
    init(withXib xibView: XibView) {
        view = xibView.getView()
    }
    
    func useJokeSet(jokes: [Joke]) {
        self.jokes = jokes
        self.jokes.shuffle()
    }
    
    func configure() {
        setupCharacters()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
            self.performNextJoke()
            // Joke Interval
            self.timer = Timer.scheduledTimer(withTimeInterval: 7, repeats: true, block: { _ in
                self.performNextJoke()
            })
        })
    }
    
    private func setupCharacters() {
        let leftController = SlimeCharacterController(withXib: view.leftCharacterView)
        let rightController = SlimeCharacterController(withXib: view.rightCharacterView)
        
        leftController.bindTo(generateCharacter())
        rightController.bindTo(generateCharacter())
        leftController.configure()
        rightController.configure()
    }
    
    private func generateCharacter() -> BehaviorSubject<UserCharacter> {
        let character = UserCharacter(named: "Test")
        character.set(color: SlimeColor.allCases.randomElement() ?? .yellow)
        character.setHat(CosmeticConstants.hatsList.randomElement()?.name ?? "none")
        character.setAccessory(CosmeticConstants.accessoriesList.randomElement()?.name ?? "none")
        
        return BehaviorSubject(value: character)
    }
    
    private func performNextJoke() {
        if jokeIndex >= jokes.count {
            return
        }
        let currentJoke = jokes[jokeIndex]
        jokeIndex = (jokeIndex + 1) % jokes.count
        
        sayJoke(currentJoke)
    }
    
    private func sayJoke(_ joke: Joke) {
        // First, ask the question
        pushDialog(text: joke.question, isLeft: true)
        
        // Then, wait for the reply
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
            self.pushDialog(text: joke.reply, isLeft: false)
            
            // Then, say the punchline
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
                self.pushDialog(text: joke.punchline, isLeft: true)
            })
        })
    }
    
    private func pushDialog(text: String, isLeft: Bool) {
        let width = view.dialogsView.frame.width
        let height = view.dialogsView.frame.height
        let dialogView = UIView.initFromNib("DialogBoxView")
        let xOffset = isLeft ? 0 : width * 0.2
        dialogView.frame = CGRect(x: xOffset, y: height, width: width * 0.8, height: 64)
        dialogView.alpha = 0
        let controller = DialogBoxController(with: dialogView)
        controller.text = text
        controller.configure()
        controller.setColor(isLeft ? "pink7" : "green7")
        controller.startAnimation(duration: 0.6)
        dialogBoxes.append(controller)
        view.dialogsView.addSubview(dialogView)
        UIView.animate(withDuration: 0.3, animations: {
            for (i, dialogBox) in self.dialogBoxes.enumerated() {
                let offsetFromBottom = self.dialogBoxes.count - i - 1
                print(offsetFromBottom)
                dialogBox.view.alpha = 1.0 - CGFloat(offsetFromBottom) * 0.15
                dialogBox.view.frame = dialogBox.view.frame.offsetBy(dx: 0, dy: -dialogView.frame.height - 8)
            }
        })
        
        if dialogBoxes.count > 8 {
            let control = dialogBoxes.removeFirst()
            control.view.removeFromSuperview()
        }
    }
    
    // Important to call this, so the timers don't run, causing deinit to not be called
    func invalidateTimers() {
        timer?.invalidate()
    }
}
