//
//  HomeTodoCell.swift
//  let.swift
//
//  Created by wenjin on 5/6/17.
//  Copyright © 2017 aaaron7. All rights reserved.
//

import Foundation
import UIKit
import BEMCheckBox

protocol HomeTodoCellDelegate {
    func didFinishedCheck(cell : HomeTodoCell)
}

class HomeTodoCell : UITableViewCell,BEMCheckBoxDelegate
{
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var mainTitle: UILabel!
    
    var delegate : HomeTodoCellDelegate?
    override func awakeFromNib()
    {
        super.awakeFromNib()
        checkBox.delegate = self
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        
    }
    
    func animationDidStop(for checkBox: BEMCheckBox) {
        if let del = delegate{
            del.didFinishedCheck(cell: self)
        }
    }
}
