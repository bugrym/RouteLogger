//
//  AlertFactory.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 03.10.2020.
//

import Foundation
import UIKit

final class AlertFactory {
    
    static func locationRestrictedAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Unable to get your location!", message: "App cannot determines where you are due to restricted permission. Open Settings and turn on Location Services.", preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Ok", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okButton)
        return alert
    }
}
