import UIKit

extension Slime {
    func resetMovement() {
        self.checkLadderInteraction()
        self.physicsBody?.affectedByGravity = !self.isContactingWithLadder
        if self.isContactingWithLadder {
            self.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        }
    }

    func jump() {
        guard let physicsBody = self.physicsBody else {
            return
        }

        guard self.isContactingWithLadder == false else {
            return
        }

        if physicsBody.velocity.dy == 0.0 {
            AudioMaster.instance.playSFX(name: "jump")
            physicsBody.applyImpulse(CGVector(dx: 0.0, dy: StageConstants.jumpSpeed))
        }

    }

    func moveLeft(withSpeed speed: CGFloat) {
        self.physicsBody?.velocity.dx = -speed * StageConstants.speedMultiplier
        self.xScale = abs(self.xScale)
    }

    func moveRight(withSpeed speed: CGFloat) {
        self.physicsBody?.velocity.dx = speed * StageConstants.speedMultiplier
        self.xScale = -abs(self.xScale)
    }

    func moveUp(withSpeed speed: CGFloat) {
        guard self.isContactingWithLadder == true else {
            return
        }

        self.physicsBody?.velocity.dy = speed * StageConstants.speedMultiplier
    }

    func moveDown(withSpeed speed: CGFloat) {
        guard self.isContactingWithLadder == true else {
            return
        }

        self.physicsBody?.velocity.dy = -speed * StageConstants.speedMultiplier
    }

    private func checkLadderInteraction() {
        guard let contactedBodies = self.physicsBody?.allContactedBodies() else {
            return
        }

        self.isContactingWithLadder = false

        for body in contactedBodies where body.node?.name == StageConstants.ladderName {
            self.isContactingWithLadder = true
            break
        }
    }
}
