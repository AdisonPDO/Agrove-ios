//
//  BLESettings.swift
//  plantR_ios
//
//  Created by Adison Pereira de oliveira on 26/07/2022.
//  Copyright © 2022 Agrove. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLESettingsDelegate: class {
    func didConnectToHardware(peripheral: CBPeripheral)
    func didStatusBLE(status: CBManagerState)
    func didFindGardenerID(gardenerID: String)
}

class BLESettings: NSObject {

    private enum Consts {
        static let ExposedServiceUUID: CBUUID = CBUUID(string: "36b42e77-4a56-49a0-9717-688c26d85d0e")
        static let WriteCharacteristicUUID: CBUUID = CBUUID(string: "e33ea801-4736-4bcc-9b2c-1f2b16fc2209")
        static let ReadCharacteristicUUID: CBUUID = CBUUID(string: "b4981410-f3c3-4795-a7d9-96d00219b5aa")
    }
    
    weak var delegate: BLESettingsDelegate?
    private let centralManager: CBCentralManager
    private var peripheral: CBPeripheral!
    private var writeCharacteric: CBCharacteristic!
    private var sendTab: [Data] = []
    private var gardenerID: String!
    
    var wifiName: String!
    var password: String!
    var owner: String!
    
    override init() {
        centralManager = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        centralManager.delegate = self
    }

    func startScan() {
        self.centralManager.scanForPeripherals(withServices: [], options: nil)
        print("ble *lance scan => ")
    }

    func stopScan() {
        centralManager.stopScan()
        print("ble *lance stopscan => ")
    }

    func connect(_ peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
        print("ble *lance connect => ")
    }
    
    func disconnect(_ peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
        print("ble *lance disconnect => ")
    }
}

// CENTRAL MANAGER
extension BLESettings: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
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
        }
        delegate?.didStatusBLE(status: central.state)
    }

    // Si un périphérique est trouvé en analysant les périphériques, la méthode déléguée suivante est également appelée. La première ligne de cette fonction établit une connexion avec le périphérique trouvé si son nom contient PlantR.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("ble *cm check => ")
        if peripheral.name?.contains("PlantR") ?? false {
            self.peripheral = peripheral
            stopScan()
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    // Si vous vous connectez avec un périphérique, la méthode déléguée suivante sera appelée. La première ligne de cette fonction spécifie le délégué. Ensuite, obtenez le service sur la deuxième ligne de la fonction.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    // Print l'error quand il y en a une.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }

}

// PERIPHERAL
extension BLESettings: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(String(data: characteristic.value!, encoding: .utf8)!)
        // GET le gardener id du capteur
        self.gardenerID = String(data: characteristic.value!, encoding: .utf8)!
        delegate?.didFindGardenerID(gardenerID: self.gardenerID!)
        //disconnect(peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Parcour les service du périphérique
        for service in peripheral.services! {
            if service.uuid == Consts.ExposedServiceUUID {
                peripheral.discoverCharacteristics(nil, for: service)
                delegate?.didConnectToHardware(peripheral: peripheral)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
         print(service.characteristics!)
        for characteristic in service.characteristics! {
            if characteristic.uuid == Consts.ReadCharacteristicUUID {
                self.peripheral.setNotifyValue(true, for: characteristic)
                print("Found read \(characteristic)")
            } else if characteristic.uuid == Consts.WriteCharacteristicUUID {
                self.writeCharacteric = characteristic
                print("Found write")
                var sendWrite = "<-__->\(wifiName!)<-_wifi_->\(password!)<-_password_->\(owner!)<-_owner_->".data(using: .utf8)!
                sendTab = []
                let maxSize = 20
                while !sendWrite.isEmpty {
                    sendTab.append(sendWrite.prefix(maxSize))
                    sendWrite = sendWrite.dropFirst(maxSize)
                }
                sendNextData()
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("Did write \(characteristic.uuid) \(error?.localizedDescription ?? "no error")")
        if characteristic == writeCharacteric {
            sendTab = Array(sendTab.dropFirst())
            sendNextData()
        }
    }
    
    private func sendNextData() {
        guard let data = sendTab.first else { return }
        peripheral.writeValue(data, for: writeCharacteric, type: .withResponse)
    }
}
