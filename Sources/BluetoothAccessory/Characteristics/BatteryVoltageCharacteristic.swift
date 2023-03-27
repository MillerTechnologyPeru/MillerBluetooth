//
//  BatteryVoltageCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import Bluetooth
import GATT

/// Accessory Battery Voltage Characteristic
public struct BatteryVoltageCharacteristic: Equatable, Hashable, AccessoryCharacteristic {
        
    public static var type: BluetoothUUID { BluetoothUUID(characteristic: .batteryVoltage) }
    
    public static var properties: BitMaskOptionSet<CharacteristicProperty> { [.read, .encrypted] } // TODO: Notifications
    
    public static var unit: CharacteristicUnit? { .volts }
    
    public init(value: Float) {
        self.value = value
    }
    
    public var value: Float
}

// MARK: - Central

public extension CentralManager {
    
    /// Read battery voltage.
    func readBatteryVoltage(
        characteristic: Characteristic<Peripheral, AttributeID>,
        service: BluetoothUUID,
        cryptoHash cryptoHashCharacteristic: Characteristic<Peripheral, AttributeID>,
        authentication authenticationCharacteristic: Characteristic<Peripheral, AttributeID>,
        key: Credential
    ) async throws -> Float {
        return try await readEncryped(
            BatteryVoltageCharacteristic.self,
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHashCharacteristic,
            authentication: authenticationCharacteristic,
            key: key
        ).value
    }
}

public extension GATTConnection {
    
    /// Read battery voltage.
    func readBatteryVoltage(
        service: BluetoothUUID = BluetoothUUID(service: .battery),
        key: Credential
    ) async throws -> Float {
        let characteristic = try self.cache.characteristic(BluetoothUUID(characteristic: .batteryVoltage), service: service)
        let cryptoHash = try self.cache.characteristic(.cryptoHash, service: .authentication)
        let authentication = try self.cache.characteristic(.authenticate, service: .authentication)
        return try await self.central.readBatteryVoltage(
            characteristic: characteristic,
            service: service,
            cryptoHash: cryptoHash,
            authentication: authentication,
            key: key
        )
    }
}
