import CoreBluetooth

protocol SimpleBluetoothIODelegate: class {
    func simpleBluetoothIO(simpleBluetoothIO: SimpleBluetoothIO, didReceiveValue value: UInt8)
}



class SimpleBluetoothIO: NSObject {
    let serviceUUID: String
    weak var delegate: SimpleBluetoothIODelegate?
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var targetService: CBService?
    var writableCharacteristic: CBCharacteristic?
	var readableCharacteristic: CBCharacteristic?

	var timer = Timer()
	
    init(serviceUUID: String, delegate: SimpleBluetoothIODelegate?) {
        self.serviceUUID = serviceUUID
        self.delegate = delegate
		super.init()
	

        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func writeValue(value: Int8) {
		print (connectedPeripheral)
		print(writableCharacteristic)
		guard let peripheral = connectedPeripheral, let characteristic = writableCharacteristic else {
			print ("HI")
			return
        }
		
		print (value)
		print (characteristic)

        let data = Data.dataWithValue(value: value)
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
	
	
	
	@objc func readData()
	{
		connectedPeripheral?.readValue(for: readableCharacteristic!)
		let data = readableCharacteristic?.value
		print(data!.int8Value())
		self.delegate?.simpleBluetoothIO(simpleBluetoothIO: self, didReceiveValue: data!.int8Value())
	//	self.postAirQData()
	}

}

extension SimpleBluetoothIO: CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		
		
		if peripheral.name != "Project Zero R2" {
			return
		}
		
        connectedPeripheral = peripheral

        if let connectedPeripheral = connectedPeripheral {
            connectedPeripheral.delegate = self
            centralManager.connect(connectedPeripheral, options: nil)
        }
        centralManager.stopScan()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
}

extension SimpleBluetoothIO: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		print("OMG WHAT")
		guard let services = peripheral.services else {
			print("WAS NOT ABLE TO CONNECT TO SERVICE ID")
            return
        }
		
		for serv in services {
			peripheral.discoverCharacteristics(nil, for: serv)
//			print(serv.characteristics)

			
		}
		print("WAS ABLE TO CONNECT TO SERVICE ID")
        targetService = services.first
        if let service = services.first {
            targetService = service
            peripheral.discoverCharacteristics(nil, for: service)
//			print(service.characteristics)
        }
    }
	
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard let characteristics = service.characteristics else {
//            return
//        }
		let characteristics = service.characteristics!
        for characteristic in characteristics {
//			print(characteristic)
			if characteristic.uuid == CBUUID.init(string: "F0001112-0451-4000-B000-000000000000")
			{
				let data = Data.dataWithValue(value: 1)
				peripheral.writeValue(data, for: characteristic, type: .withResponse)
			}
			if characteristic.uuid == CBUUID.init(string: "F000BEEF-0451-4000-B000-000000000000")
			{
				print("YES")
				peripheral.readValue(for: characteristic)
				let data = characteristic.value
				
				if let myValue = data?.int8Value(){
					print(myValue)
					self.delegate?.simpleBluetoothIO(simpleBluetoothIO: self, didReceiveValue: data!.int8Value())
					readableCharacteristic = characteristic
					timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(readData), userInfo: nil, repeats: true)
				}
			}
			if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                writableCharacteristic = characteristic
            }
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value, let delegate = delegate else {
            return
        }

        delegate.simpleBluetoothIO(simpleBluetoothIO: self, didReceiveValue: data.int8Value())
    }
	

}
