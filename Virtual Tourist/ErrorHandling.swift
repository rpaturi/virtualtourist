//
//  ErrorHandling.swift
//  Virtual Tourist
//
//  Created by Rachel Paturi on 7/9/16.
//  Copyright © 2016 Rachel Paturi. All rights reserved.
//

import UIKit

func createAlertError(title: String, message: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(action)
    return alert
}
