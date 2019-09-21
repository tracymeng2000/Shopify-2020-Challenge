//
//  ViewController.swift
//  shopify2020CodingChallenge
//
//  Created by Tracy Meng on 2019-09-11.
//  Copyright © 2019 Tracy Meng. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    //NOT_STARTED: The game is not started
    //ZERO_FLIPPED: The game is started but no cards has been flipped except the matched ones
    //FLIPPED: The game has at least one card flipped except the matched ones
    //SUCCESS: The user has matched all cards and the game is successfully finished
    private enum GameState{
        case NOT_STARTED, ZERO_FLIPPED, FLIPPED, SUCCESS
    }
    
    var imageList = [UIImage]() //list of images obtained from Shopify's API
    var score : Int = 0 //current score
    var displayTime : Double = 2.0 //time to display unmatched cards for
    private var currentGameState : GameState = GameState.NOT_STARTED
    var flippedCards = [Card]() //array of cards currently flipped
    var requiredPairing : Int = 2 //required number of card match to win, configurable by user
    let requiredPairingOptions = [2,4,5] //the possible options for requiredPairing
    var numberOfCards : Int = 20 //total number of cards in game
    
    
    @IBOutlet var cardList: [Card]!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.scoreLabel.text = "SCORE: \(self.score)"
        //to enhance gameplay experience:
        //display time will be divided by requiredPairing to determine final display time
        self.displayTime = self.displayTime / Double(self.requiredPairing)
    }

    //cardPressed flip cards and change gameState accordingly
    @IBAction func cardPressed(sender: Card){
        sender.isEnabled = false
        if !self.flippedCards.contains(sender){
            sender.flipCard()
            flippedCards.append(sender)
            
            switch self.currentGameState {
            case GameState.ZERO_FLIPPED:
                self.currentGameState = GameState.FLIPPED
            case GameState.FLIPPED:
                if self.isMatched(){
                    if self.requiredPairing == self.flippedCards.count{
                        //cards matched
                        self.flippedCards.removeAll()
                        self.currentGameState = GameState.ZERO_FLIPPED
                        self.incrementScore()
                    }
                }else{
                    //cards didn't match
                    let tempCard = self.flippedCards
                    self.flippedCards.removeAll()
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.displayTime, execute: {
                        for card in tempCard{
                            card.flipCard()
                            card.isEnabled = true
                        }
                    })
                    self.currentGameState = GameState.ZERO_FLIPPED
                }
            default:
                //This code block will never get executed since all cards will be disabled
                ///whenever currentGameState is NOT_STARTED or SUCCESS
                break
            }
        }
    }
    
    //settingPressed being up alert to let user choose the requiedMatch
    @IBAction func settingPressed(_ sender: Any) {
        let requiredMatchSelectionController = UIAlertController(title: "How many card is a match?", message:
            "Please select one or cancel", preferredStyle: .actionSheet)
        for i in self.requiredPairingOptions {
            requiredMatchSelectionController.addAction(UIAlertAction(title: String(i), style: .default, handler: {
                _ -> () in
                if self.requiredPairing != i {
                    //adjust display time and change to new selection
                    self.displayTime = self.displayTime * Double(self.requiredPairing) / Double(i)
                    self.requiredPairing = i
                }
            }))
        }
        requiredMatchSelectionController.addAction(UIAlertAction(title: "cancel", style: .cancel))
        self.present(requiredMatchSelectionController, animated: true, completion: nil)
    }
    
    //starts or ends the game depends on currentGameState
    @IBAction func startButtonPressed(_ sender: UIButton) {
        if self.currentGameState == GameState.NOT_STARTED {
            self.startGame()
        }else if self.currentGameState == GameState.SUCCESS{
            self.endGame()
            self.startGame()
        }else{
            self.endGame()
        }
    }
    
    //check if all the cards in the flippedCards array are matched
    func isMatched() -> Bool{
        var prevCardTag : Int = -1
        for card in self.flippedCards{
            if (prevCardTag != -1) && (card.tag / self.requiredPairing != prevCardTag / requiredPairing){
                return false
            }
            prevCardTag = card.tag
        }
        return true
    }
    
    //increment the game score, if score equals winning score, alerts the user with a success message
    func incrementScore(){
        self.score += 1
        self.scoreLabel.text = "SCORE: \(self.score)"
        if score == (self.numberOfCards / self.requiredPairing){
            self.currentGameState = GameState.SUCCESS
            self.updateButtons()
            self.displayWinningModal()
        }
    }
    
    //displays a winning message with the option to share the game with friends
    func displayWinningModal() {
        let winningMessageController = UIAlertController(title: "🤩Congrats!🥳", message:
            "You won the game!", preferredStyle: .alert)
        winningMessageController.addAction(UIAlertAction(title: "OK!", style: .default))
        winningMessageController.addAction(UIAlertAction(title: "Share with Friends", style: .default, handler: {
            //set up for sharing
            _ -> Void in
            let firstActivityItem = "I just won the memory game 😃"
            UIGraphicsBeginImageContext(self.view.frame.size)
            self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let winningScreenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [firstActivityItem, winningScreenshot!], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }))
        self.present(winningMessageController, animated: true, completion: nil)
    }
    
    //update UI for startButton and settingButton according to currentGameState
    private func updateButtons(){
        switch currentGameState {
        case GameState.NOT_STARTED:
            startButton.setTitle("START", for: UIControl.State.normal)
            startButton.setTitleColor(UIColor.orange, for: UIControl.State.normal)
            settingButton.isEnabled = true
        case GameState.SUCCESS:
            startButton.setTitle("RESTART", for: UIControl.State.normal)
            startButton.setTitleColor(UIColor.orange, for: UIControl.State.normal)
            settingButton.isEnabled = true
        default:
            startButton.setTitle("END", for: UIControl.State.normal)
            startButton.setTitleColor(UIColor.red, for: UIControl.State.normal)
            settingButton.isEnabled = false
        }
    }
    
    //shuffles cards and images and starts the game
    func startGame(){
        imageList.shuffle()
        cardList.shuffle()
        for i in 0...(self.numberOfCards - 1){
            if cardList[i].getFlipped(){
                cardList[i].flipCard()
            }
            cardList[i].setCardImage(updatedImage: imageList[i / requiredPairing])
            cardList[i].tag = i
            cardList[i].isEnabled = true
        }
        self.currentGameState = GameState.ZERO_FLIPPED
        self.updateButtons()
    }
    
    //ends the game, resets all properties
    func endGame(){
        for i in 0...(self.numberOfCards - 1){
            cardList[i].isEnabled = false
        }
        self.flippedCards.removeAll()
        self.score = 0
        self.scoreLabel.text = "SCORE: \(score)"
        self.currentGameState = GameState.NOT_STARTED
        self.updateButtons()
    }
}

