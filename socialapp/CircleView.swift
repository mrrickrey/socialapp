//
//  CircleView.swift
//  socialapp
//
//  Created by Enrique Reyes on 3/30/17.
//  Copyright © 2017 Enrique Reyes. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func layoutSubviews() {
        
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }
}
