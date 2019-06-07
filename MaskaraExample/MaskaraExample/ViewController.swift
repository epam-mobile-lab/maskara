//
//  ViewController.swift
//  MaskaraExample
//
//  Created by Evgeny Kamyshanov on 10/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import UIKit
import Maskara

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var maskara: MaskaraTextField!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var maskField: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        maskara.delegate = self
        maskara.maskPattern = "+?7|8(DDD)DDD-| ?DD-| ?DD"
        maskField.text = maskara.maskPattern
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        result.text = maskara.extractedText
        return true
    }
}

