//
//  AlertManager.swift
//  Weather
//
//  Created by Гоша Бодров on 23.11.2018.
//  Copyright © 2018 Гоша Бодров. All rights reserved.
//

import Foundation
import UIKit

class AlertManager {
    func creatAlert(title: String, message: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        return alertController
    }
}
