//
//  HRMReader.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 26/09/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//
import Foundation


protocol HRMReaderDelegate: class {
    func didUpdate(bpm: Int)
    func didEncounter(error: String)
}

class HRMReader: NSObject {
    
    // from https://www.bluetooth.com/specifications/gatt/services/
    enum BluetoothGATT: String {
        case heartRateServiceId = "0x180D"
        case heartRateMeasurementCharacteristicID = "0x2A37"
    }
    
    weak var delegate: HRMReaderDelegate?
    
    var centralManager: CBCentralManager!
    var hrmPeripheral: CBPeripheral?
    var subscribedCharacteristic: CBCharacteristic?
    
    var mockHRM: MockBluetoothHRM?
    
    init(delegate: HRMReaderDelegate) {
        self.delegate = delegate
        super.init()
        
        #if targetEnvironment(simulator)
        mockHRM = MockBluetoothHRM()
        mockHRM?.setupMockHeartRateMonitor()
        #endif

        createCentral()
    }
    
    func willDeactivate() {
        // save energy by disconnecting and allowing the radio to power down.
        // See "Disconnect from a Device When You No Longer Need It
        // https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/BluetoothBestPractices.html
        if let characteristic = subscribedCharacteristic {
            hrmPeripheral?.setNotifyValue(false, for: characteristic)
            subscribedCharacteristic = nil
        }
        if let peripheral = hrmPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        
        #if targetEnvironment(simulator)
        mockHRM?.tearDownMockHeartRateMonitor()
        #endif
    }
    
    private func createCentral() {
        centralManager = CBCentralManagerFactory.instance(delegate: self, queue: nil)
    }
}

extension HRMReader: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
            
        case .unsupported:
            delegate?.didEncounter(error: "Sorry your device does not support Bluetooth.")
        case .unauthorized:
            delegate?.didEncounter(error: "Please authorise Bluetooth access.")
        case .poweredOff:
            delegate?.didEncounter(error: "Please switch Bluetooth on.")
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: [ hrmServiceID() ], options:  nil)
        default:
            delegate?.didEncounter(error: "Unhandled Bluetooth error.")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        print("didDiscover peripheral: \(peripheral)")
        
        // avoid connecting to multiple HRMs and loosing the reference
        guard self.hrmPeripheral == nil else { return }
        
        self.hrmPeripheral = peripheral
        
        // scanning is expensive
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        
        print("didConnect peripheral: \(peripheral)")
        
        self.hrmPeripheral?.delegate = self
        self.hrmPeripheral?.discoverServices([ hrmServiceID() ])
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        
        print("didFailToConnect peripheral: \(peripheral)")
        
        var errorMessage = "Peripheral failed to connect"
        
        if let error = error {
            errorMessage += ": \(error.localizedDescription)"
        }
        delegate?.didEncounter(error: errorMessage)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        
        print("didDisconnectPeripheral peripheral: \(peripheral)")
        
        if let error = error {
            delegate?.didEncounter(error: "Peripheral disconnected: \(error.localizedDescription)")
        }
        hrmPeripheral = nil
        // attempt to reconnect
        createCentral()
    }
    
    private func hrmServiceID() -> CBUUID {
        CBUUID(string: BluetoothGATT.heartRateServiceId.rawValue)
    }
}

extension HRMReader: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        
        print("didDiscoverServices peripheral: \(peripheral)")
        
        if let error = error {
            delegate?.didEncounter(error: "Service discovery error: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services,
            let peripheral = self.hrmPeripheral else { return }
        
        for service in services {
            peripheral.discoverCharacteristics([ hrmCharacteristicID() ],
                                               for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        
        print("didDiscoverCharacteristics peripheral: \(peripheral) service: \(service)")
        
        if let error = error {
            delegate?.didEncounter(error: "Characteristics discovery error: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == hrmCharacteristicID() {
                peripheral.setNotifyValue(true, for: characteristic)
                subscribedCharacteristic = characteristic
                return
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        print("didUpdateValueFor peripheral: \(peripheral) characteristic: \(characteristic)")
        
        if let error = error {
            delegate?.didEncounter(error: "Characteristic update value error: \(error.localizedDescription)")
            return
        }
        
        if let bpm = heartRateBPM(from: characteristic) {
            delegate?.didUpdate(bpm: bpm)
        }
    }
    
    private func hrmCharacteristicID() -> CBUUID {
        CBUUID(string: BluetoothGATT.heartRateMeasurementCharacteristicID.rawValue)
    }
    
    // TODO throw, rather than returning nil on error case
    private func heartRateBPM(from characteristic: CBCharacteristic) -> Int? {
        
        guard let characteristicData = characteristic.value else { return nil }
        
        let byteArray = [UInt8](characteristicData)
        
        if byteArray.count <= 1 { return nil }
        
        // format described here: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=239866
        // (Two byte format supports BPMs > 255)
        let isOneByteBPM = (byteArray[0] & 0x01 == 0)
        if isOneByteBPM {
            return Int(byteArray[1])
        } else if byteArray.count >= 2 {
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        } else {
            return nil
        }
    }
}
