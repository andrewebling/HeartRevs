//
//  ViewController.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 23/09/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import UIKit

class HeartRateMonitorViewController: UIViewController {
    
    let notificationCenter = NotificationCenter.default
    var hrmReader: HRMReader?
    @IBOutlet weak var label: UILabel!
    var placeholderText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeholderText = self.label.text
        observeNotifications()
    }
     

    func show(_ error: String) {
        present(errorMessage(error), animated: true, completion: nil)
    }
    
    private func errorMessage(_ error: String) -> UIViewController {
        let ac = UIAlertController(title: "Error",
                                   message: error,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return ac
    }
    
    private func observeNotifications() {
        
        notificationCenter.addObserver(forName: UIScene.willEnterForegroundNotification, object: nil, queue: nil) { _ in
            self.hrmReader = HRMReader(delegate: self)
        }
        
        notificationCenter.addObserver(forName: UIScene.willDeactivateNotification, object: nil, queue: nil) { _ in
            self.hrmReader?.willDeactivate()
            self.hrmReader = nil
            self.label.text = self.placeholderText
        }
    }
}

extension HeartRateMonitorViewController: HRMReaderDelegate {
    
    func didUpdate(bpm: Int) {
        label.text = String(describing: bpm)
    }
    
    func didEncounter(error: String) {
        show(error)
    }
}
