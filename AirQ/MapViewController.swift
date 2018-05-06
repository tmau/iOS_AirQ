//
//  MapViewController.swift
//  HelloBluetooth
//
//  Created by Taylor Mau on 4/11/18.
//  Copyright © 2018 Nebojsa Petrovic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
	@IBOutlet var mapView: MKMapView!
	var locationManager: CLLocationManager!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setUpMapView()
		checkLocationAuthorizationStatus()
//		locationManager.delegate = self as! CLLocationManagerDelegate
//		locationManager.startUpdatingLocation()
		updateLocation()

        // Do any additional setup after loading the view.
    }
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setUpMapView()
	{
		 locationManager = CLLocationManager()
	}
	
	func checkLocationAuthorizationStatus() {
		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
			mapView.showsUserLocation = true
		} else {
			locationManager.requestWhenInUseAuthorization()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		checkLocationAuthorizationStatus()
	}
	
	func updateLocation()
	{
		locationManager.startUpdatingLocation()
		var currentLocation = locationManager.location
		var scalingFactor = abs(cos(2*3.1415926*(currentLocation?.coordinate.latitude)!/360))
		var spanX = 0.004/1000.0
		var spanY = 0.004/(scalingFactor*1000.0)
		var span = MKCoordinateSpan()
		span.latitudeDelta = spanX
		span.longitudeDelta = spanY
		
		var region = MKCoordinateRegion()
		region.center.latitude = (currentLocation?.coordinate.latitude)!
		region.center.longitude = (currentLocation?.coordinate.longitude)!
		
		region.span = span
		mapView.setRegion(region, animated: false)
	}

}
