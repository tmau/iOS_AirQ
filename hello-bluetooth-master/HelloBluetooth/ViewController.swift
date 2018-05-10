import UIKit
import CoreBluetooth
import CoreLocation

class ViewController: UIViewController {
    var simpleBluetoothIO: SimpleBluetoothIO!

    @IBOutlet weak var ledToggleButton: UIButton!

	@IBOutlet var AirQData: UILabel!
	
	@IBOutlet var Connected: UIBarButtonItem!
	
	@IBAction func pressedReconnectButton(_ sender: Any) {
		self.simpleBluetoothIO.centralManager.connect(self.simpleBluetoothIO.connectedPeripheral!, options: nil)
	}
	
	@IBOutlet var humid: UILabel!
	@IBOutlet var temp: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		checkLocationAuthorizationStatus() //add
		updateLocation() //add
        simpleBluetoothIO = SimpleBluetoothIO(serviceUUID: "F0001110-0451-4000-B000-000000000000", delegate: self)
//		simpleBluetoothIO = SimpleBluetoothIO(serviceUUID: "F000ABBA-0451-4000-B000-000000000000", delegate: self)
    }
//	F000ABBA-0451-4000-B000-000000000000
//	19B10010-E8F2-537E-4F6C-D104768A1214

//    @IBAction func ledToggleButtonDown(_ sender: UIButton) {
//        simpleBluetoothIO.writeValue(value: 1)
//		print("Sending Value: 0x01")
//    }
//
//    @IBAction func ledToggleButtonUp(_ sender: UIButton) {
//        simpleBluetoothIO.writeValue(value: 0)
//    }

	var locationManager: CLLocationManager!
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
//	func setUpMapView()
//	{
////		locationManager = CLLocationManager()
//	}
	
	func checkLocationAuthorizationStatus() {
		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//			mapView.showsUserLocation = true
		} else {
			locationManager.requestWhenInUseAuthorization()
		}
	}

	func updateLocation()
	{
		locationManager = CLLocationManager()
		locationManager.startUpdatingLocation()
//		locationManager = locationManager!.location
	}
	
	func postAirQData(data :UInt8 ) {
		
//		connectedPeripheral?.readValue(for: readableCharacteristic!)
//		let data = readableCharacteristic?.value
		print(data)
		print("STRING FORMAT IS: ")
		print((String(format: "%d", (data))))
//		let parameters = ["value": "\(String(format: "%d", (data)))"]
		let parameters = ["value": "\(String(format: "%d", (data)))", "lat": "\(String(format: "%f", (locationManager.location?.coordinate.latitude)!))", "lon": "\(String(format: "%f", (locationManager.location?.coordinate.longitude)!))"]
		guard let url = URL(string: "https://io.adafruit.com/api/feeds/data/data.json?X-AIO-Key=8250e91368af4527b937c436afe799a1") else { return }
		print(parameters)
		
		//		var dictionary = NSMutableDictionary()
		//		dictionary.setValue(data!.int8Value(), forKey: "value")
		//		dictionary.setValue(123, forKey: "lat")
		//		dictionary.setValue(43, forKey: "long")
		
		
		//		let newBody = JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
		//JSONSerialization.jsonObject(with: data, options: [])
		//		print(json)
		
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
		request.httpBody = httpBody
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			if let response = response {
				print(response)
			}
			if let data = data {
				do {
					//					let json = try
					
					
				} catch {
					print(error)
				}
			}
			}.resume()
	}
}

extension ViewController: SimpleBluetoothIODelegate {
//	func simpleBluetoothIO(simpleBluetoothIO: SimpleBluetoothIO, didReceiveValue value: UInt8, temp: UInt8, humid: UInt8)
	func simpleBluetoothIO(simpleBluetoothIO: SimpleBluetoothIO, didReceiveValue value: UInt8){
		
		
        if simpleBluetoothIO.connectedPeripheral?.state == CBPeripheralState.connected  {
			self.Connected.title = String.init("Connected")
        } else {
			self.Connected.title = String.init("Reconnected")
        }
		self.AirQData.text = String.init(format: "%d ", arguments: [value])
//		self.humid.text = String.init(format: "%d ", arguments: [temp])
//		self.temp.text = String.init(format: "%d ", arguments: [humid])
		
		self.postAirQData(data: value)
    }
}
