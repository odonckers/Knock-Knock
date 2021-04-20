//
//  LocationManager.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Combine
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    @Published var status: CLAuthorizationStatus? {
        willSet { objectWillChange.send() }
    }
    @Published var location: CLLocation? {
        willSet { objectWillChange.send() }
    }
    @Published var placemark: CLPlacemark? {
        willSet { objectWillChange.send() }
    }

    let objectWillChange = PassthroughSubject<Void, Never>()

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func request(_ request: LocationRequest = .whenInUse) {
        switch request {
        case .always: locationManager.requestAlwaysAuthorization()
        case .whenInUse: locationManager.requestWhenInUseAuthorization()
        }

        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingPlacement() {
        locationManager.stopUpdatingLocation()
    }
    
    func whenAuthorized(completionHandler: @escaping (_ placement: CLPlacemark?) -> ()) {
        guard let status = status else { return }

        if status == .authorizedAlways || status == .authorizedWhenInUse {
            completionHandler(placemark)
        } else {
            request()
        }
    }
    
    private func geocode() {
        guard let location = location else { return }

        geocoder.reverseGeocodeLocation(location) { [weak self] places, error in
            if error == nil { self?.placemark = places?[0] }
            else { self?.placemark = nil }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        self.status = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        self.location = location
        self.geocode()
    }
}
