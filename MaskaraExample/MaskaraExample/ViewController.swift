//
//  ViewController.swift
//  MaskaraExample
//
//  Created by Evgeny Kamyshanov on 10/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import UIKit
import Maskara
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var maskara: MaskedTextField!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var maskField: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try maskara.setMaskPattern(mask: "+?7|8(DDD)D|XD|XD|X-| ?D|XD|X-| ?D|XD|X")
            maskField.text = maskara.maskPattern
        } catch let error {
            maskField.text = "Unable to set mask: \(error)"
            maskField.textColor = UIColor.red
        }

        maskara.matchErrorHandler = { _ in
            AudioServicesPlaySystemSound(1103)
        }

        maskara.delegate = self
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let extractedText = maskara.extractedText else {
            return true
        }

        switch extractedText {
        case .complete(let text):
            result.text = text
            resultLabel.text = "COMPLETE result"
        case .partial(let text):
            result.text = text
            resultLabel.text = "PARTIAL result"
        }

        return true
    }
}

