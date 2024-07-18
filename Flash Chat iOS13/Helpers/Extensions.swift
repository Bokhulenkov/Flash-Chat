//
//  Extensions.swift
//  Flash Chat iOS13
//
//  Created by Alexander Bokhulenkov on 18.07.2024.
//  Copyright © 2024 Angela Yu. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
}
