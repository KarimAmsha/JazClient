import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var address: String = ""

    private var locationCompletion: ((CLLocationCoordinate2D?) -> Void)?

    override private init() {
        super.init()
        setupLocationManager()
    }

    // هذه الدالة يستدعيها الفيو لمرة واحدة فقط
    func requestLocationIfNeeded() {
        if userLocation == nil {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
    }

    func getCurrentLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        locationCompletion = completion
        locationManager.requestLocation()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            locationCompletion?(nil)
            return
        }

        let coordinate = location.coordinate
        self.userLocation = coordinate
        locationCompletion?(coordinate)
        fetchAddress(from: location)

        // Stop updating after getting location
        stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
        locationCompletion?(nil)
    }

    private func fetchAddress(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                self.address = "Address not found"
                return
            }

            if let placemark = placemarks?.first {
                let addressString = [
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.postalCode,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")

                DispatchQueue.main.async {
                    self.address = addressString
                }
            }
        }
    }
}
