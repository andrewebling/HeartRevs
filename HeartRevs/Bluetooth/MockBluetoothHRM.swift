//
//  MockBluetoothHRM.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 06/10/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//
import Foundation
import CoreBluetoothMock

class MockBluetoothHRM {
    
     func setupMockHeartRateMonitor() {
        CBMCentralManagerMock.simulateInitialState(.poweredOn)
        
        let peripheralSpec = mockHRM()
        CBMCentralManagerMock.simulatePeripherals([ peripheralSpec ])
        
        let delayTime = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
//            let bytes: [UInt8] = [ 0x00, 0x3E ] // single byte format, 62 BPM
            let bytes: [UInt8] = [ 0x01, 0x00, 0x3E ] // two byte format, 62 BPM
            peripheralSpec.simulateValueUpdate(Data(bytes), for:self.mockHRMCharacteristic)
        }
        
    }
    
    func tearDownMockHeartRateMonitor() {
        CBMCentralManagerMock.tearDownSimulation()
    }
    
    struct DummyPeripheralSpecDelegate: CBMPeripheralSpecDelegate { }
    
    let mockHRMCharacteristic = CBMCharacteristicMock(
        type: CBMUUID(string: "2A37"),
        properties: [.notify],
        descriptors: CBMClientCharacteristicConfigurationDescriptorMock()
    )
    
    private func mockHRMService() -> CBMServiceMock {
        
        CBMServiceMock(
            type: CBMUUID(string: "0x180D"),
            primary: true,
            characteristics:
            mockHRMCharacteristic,
            CBMCharacteristicMock(
                type: CBMUUID(string: "0x2A38"),
                properties: [.read])
        )
    }
    
    private func mockHRM() -> CBMPeripheralSpec {
        CBMPeripheralSpec
            .simulatePeripheral(proximity: .immediate)
            .advertising(advertisementData: [
                CBMAdvertisementDataLocalNameKey : "MockHRM",
                CBMAdvertisementDataServiceUUIDsKey : [
                    CBMUUID(string: "0x180D"),
                    CBMUUID(string: "0x180A")
                ],
                CBMAdvertisementDataIsConnectable : true as NSNumber
                ],
                         withInterval: 0.1)
            .connectable(
                name: "MockHRM",
                services: [ mockHRMService()],
                delegate: DummyPeripheralSpecDelegate(),
                connectionInterval: 0.25,
                mtu: 251)
            .build()
    }
}
