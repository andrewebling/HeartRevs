//
//  ViewController.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 23/09/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {

    var centralManager: CBCentralManager!
    var hrm: CBPeripheral!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState: \(central)")
        // [CBUUID(string: "B597C7B9-7593-67DB-C42A-07792987E71E")]
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        self.hrm = peripheral
//        print("didDiscoverPeripheral: \(self.hrm)")
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("didConnect: \(peripheral)")
//        self.hrm = peripheral
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        print("didFailToConnect: \(peripheral)")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("didDisconnectPeripheral: \(peripheral)")
    }
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        
        print("connectionEventDidOccur \(event) - peripheral: \(peripheral)")
    }
    
    func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        print("didUpdateANCSAuthorizationFor \(peripheral)")
    }
}

