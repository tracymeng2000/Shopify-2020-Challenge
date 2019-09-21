//
//  Card.swift
//  shopify2020CodingChallenge
//
//  Created by Tracy Meng on 2019-09-12.
//  Copyright © 2019 Tracy Meng. All rights reserved.
//

import UIKit

class Card : UIButton {
    private var backGroundImage : UIImage?
    private var flipped : Bool
    private let flipDuration : Double = 0.3
    
    override init(frame: CGRect){
        self.flipped = false
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.adjustsImageWhenHighlighted = false
        self.adjustsImageWhenDisabled = false
        self.isEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.flipped = false
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.adjustsImageWhenHighlighted = false
        self.adjustsImageWhenDisabled = false
        self.isEnabled = false
    }
    
    func getFlipped() -> Bool{
        return self.flipped
    }
    
    func setCardImage(updatedImage : UIImage){
        self.backGroundImage = updatedImage
    }
    
    func flipCard(){
        if(self.flipped){
            self.setBackgroundImage(nil, for: UIControl.State.normal)
            self.flipped = false
        }else{
            self.setBackgroundImage(self.backGroundImage, for: UIControl.State.normal)
            self.flipped = true
        }
        //add flipping effect
        UIView.transition(with: self, duration: self.flipDuration, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    
    
}


