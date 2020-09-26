//
//  ViewController.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 23/09/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    var centralManager: CBCentralManager!
    var hrmPeripheral: CBPeripheral!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension ViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState: \(central)")
        
        // from https://www.bluetooth.com/specifications/gatt/services/
        let hrmCBUUID = "0x180D"
        
        switch central.state {
            
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [ CBUUID(string: hrmCBUUID) ])
        @unknown default:
            print("central.state is default case")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        // avoid connecting to multiple HRMs and loosing the reference
        guard self.hrmPeripheral == nil else { return }
        
        self.hrmPeripheral = peripheral
        
        // scanning is expensive
        centralManager.stopScan()
        centralManager.connect(self.hrmPeripheral)
        

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("didConnect: \(peripheral)")
        
        self.hrmPeripheral.delegate = self
        self.hrmPeripheral.discoverServices(nil)
        
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

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("Service: \(service) - characteristics: \(String(describing: service.characteristics))")
            self.hrmPeripheral.discoverCharacteristics(nil, for: service)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("Characteristic: \(characteristic)")
            if characteristic.uuid == CBUUID(string: "0x2A37") {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let bpm = heartRateBPM(from: characteristic) {
            print("BPM: \(String(describing: bpm))")
            self.label.text = String(describing: bpm)
        }
    }
    
    private func heartRateBPM(from characteristic: CBCharacteristic) -> Int? {
        
        guard let characteristicData = characteristic.value else { return nil }
        
        let byteArray = [UInt8](characteristicData)
        
        // format described here: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=239866
        let isOneByteBPM = (byteArray[0] & 0x01 == 0)
        if isOneByteBPM {
            return Int(byteArray[1])
        } else {
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
}
