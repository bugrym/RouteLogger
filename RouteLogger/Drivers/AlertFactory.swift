//
//  AlertFactory.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 03.10.2020.
//  Quality Assurance by Kateryna Galushka
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
    
    static func routeSavingAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Route has successfully saved!", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okButton)
        return alert
    }
    
    static func centerDeterminationAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Impossible to determine", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okButton)
        return alert
    }
    
    static func deleteAllRoutes(comletionHandler:@escaping()->Void) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to delete all routes?", preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Yes", style: .default) { _ in
            comletionHandler()
        }
        
        let noButton = UIAlertAction(title: "No", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(yesButton)
        alert.addAction(noButton)
        return alert
    }
}
