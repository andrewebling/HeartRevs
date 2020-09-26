//
//  ViewController.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 23/09/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var hrmReader: HRMReader!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hrmReader = HRMReader()
        hrmReader.delegate = self
    }
    
    func show(_ error: String) {
        let ac = UIAlertController(title: "Error",
                                   message: error,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(ac, animated: true, completion: nil)
    }
}

extension ViewController: HRMReaderDelegate {
    
    func didUpdate(bpm: Int) {
        label.text = String(describing: bpm)
    }
    
    func didEncounter(error: String) {
        show(error)
    }
}
