//
//  ETAPopOverController.swift
//  findmybusnj
//
//  Created by David Aghassi on 1/18/16.
//  Copyright © 2016 David Aghassi. All rights reserved.
//

import Foundation
import UIKit

// MARK: Dependancies
import NetworkManager

class ETAPopOverController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var stopNumberInput: UITextField!
    @IBOutlet weak var filterBusNumberInput: UITextField!
    @IBOutlet weak var favoritesTableView: UITableView!

    // MARK: UITextFieldDelegate Methods
    // Source of idea: http://stackoverflow.com/questions/433337/set-the-maximum-character-length-of-a-uitextfield?rq=1
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // If the current character count is nil, we set it to zero using nil coelescing
        let currentCharCount = textField.text?.characters.count ?? 0;
        if (range.length + range.location > currentCharCount) {
            return false
        }
        let newLength = currentCharCount + string.characters.count - range.length
        
        // Stop textField
        if (textField.tag == 0) {
            return newLength <= 5
        }
        //Bus textField
        else if (textField.tag == 1) {
            return newLength <= 3
        }
        else {
            return false
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: Segue
    // Source of idea: http://jamesleist.com/ios-swift-tutorial-stop-segue-show-alert-text-box-empty/
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "search") {
            let warn = UIAlertView(title: "No stop entered", message: "Please enter a stop before searching", delegate: nil, cancelButtonTitle: "Ok")
            
            // Check to see if user entered a stop number
            guard let stop = stopNumberInput.text else {
                warn.show()
                return false
            }
            if (stop.isEmpty) {
                warn.show()
                return false
            }
        }
        
        return true
    }
}