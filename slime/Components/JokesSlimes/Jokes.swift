//
//  Jokes.swift
//  slime
//
//  Created by Gabriel Tan on 10/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

struct Joke {
    let question: String
    let reply: String
    let punchline: String
    
    init(_ question: String, _ reply: String, _ punchline: String) {
        self.question = question
        self.reply = reply
        self.punchline = punchline
    }
}

enum JokeConstants {
    static let setOne = [
        Joke("Why aren't koalas actual bears?", "Why?", "They don't meet the koalafications."),
        Joke("What's brown and sticky?", "What?", "A stick."),
        Joke("What do you call a fake noodle?", "What?", "An Impasta."),
        Joke("What do you call an alligator in a vest?", "What?", "An investigator."),
        Joke("What's the difference between a guitar and a fish?", "I don't know.", "You can't tuna fish."),
        Joke("What do you get from a pampered cow?", "I don't know.", "Spoiled milk."),
        Joke("Did you hear about that new broom?", "No?", "It's sweeping the nation!"),
        Joke("What do you call an elephant that doesn't matter?", "I don't know.", "An irrelephant."),
        Joke("What do you call a pile of kittens?", "Many cats?", "A meowntain."),
        Joke("Why did the picture go to jail?", "Enlighten me.", "Because it was framed."),
        Joke("What do you call a laughing jar of mayonnaise?", "Mayonnaise?", "LMAYO."),
        Joke("What do you call sad coffee?", "A coffee?", "Depresso.")
    ]
}
