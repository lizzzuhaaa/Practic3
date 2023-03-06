//
//  MyCustomCell.swift
//  Practic2
//
//  Created by лізушка лізушкіна on 03.03.2023.
//

import Foundation
import UIKit

final class MyCustomCell : UITableViewCell
{
    
    @IBOutlet private weak var backgroud: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var upperLabel: UILabel!
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize = super.sizeThatFits(size)
        newSize.height = 200
        return newSize
    }
    
    func config(reddit: [String:String])
    {
        
        self.backgroud = self.backgroundView
        if let title = reddit["Title"],
           let upper = reddit["UpperLabel"]
        {
            self.upperLabel.text = upper
            self.titleLabel.text = title
            self.titleLabel.numberOfLines=0
            self.titleLabel.lineBreakMode = .byWordWrapping
            self.titleLabel.preferredMaxLayoutWidth = 380
            let sizeText = self.titleLabel.sizeThatFits(CGSize(width: self.titleLabel.frame.size.width, height: self.titleLabel.frame.size.height))
                if(sizeText.height > self.titleLabel.frame.size.height)
                {
                    self.titleLabel.adjustsFontSizeToFitWidth = true
                }
        }
        
    }
}
