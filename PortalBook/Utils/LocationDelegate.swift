//
//  LocationDelegate.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/26/23.
//

import Foundation
import CoreLocation
import MapKit

class LocationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var location: String?

    override init() {
        super.init()

        locationManager.delegate = self
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationDelegate: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.geocoder.reverseGeocodeLocation(location) { placemark, error in
                if let error = error {
                    print(error)
                } else {
                    print(placemark?.first)

                    self.location = placemark?.first?.postalCode
                }
            }
        }
    }
}
