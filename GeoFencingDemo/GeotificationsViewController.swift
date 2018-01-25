//
//  GeotificationsViewController.swift
//  GeoFencingDemo
//
//  Created by zhanggui on 2018/1/23.
//  Copyright © 2018年 zhanggui. All rights reserved.
//
struct PreferenceKeys {
    static let savedItems = "savedItems"
}


import UIKit
import MapKit
class GeotificationsViewController: UIViewController {
 

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager.init()
    
    var geotifications: [Geotification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.userTrackingMode = .followWithHeading
        mapView.showsBuildings = true//展示楼房
        mapView.showsPointsOfInterest = true  //
        mapView.showsScale = true   //展示比例尺
        mapView.showsTraffic = true
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        loadAllGeotifications()
       
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addShow" {
            let navigationController = segue.destination as! UINavigationController
            let vc = navigationController.viewControllers.first as! AddGeotificationViewController
            vc.delegate = self
        }
    }
    @IBAction func showAddAction(_ sender: Any) {
        self.performSegue(withIdentifier: "addShow", sender: nil)
    }


    
    @IBAction func getCurrentLocationAction(_ sender: Any) {
        mapView.zoomToUserLocation()
    }
    func loadAllGeotifications() {
        geotifications = []
        guard let savedItems = UserDefaults.standard.array(forKey: PreferenceKeys.savedItems) else { return }
        for savedItem in savedItems {
            guard let geotification = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? Geotification else { return }
            add(geotification: geotification)

        }
    }
    func add(geotification: Geotification) {
        geotifications.append(geotification)
        mapView.addAnnotation(geotification)
        addRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
        
    }
    func updateGeotificationsCount() {
        title = "Geotifications (\(geotifications.count))"
        navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20)  //超过20个不添加
    }
    //根据geotification来获取region
    func region(withGeotification geotification: Geotification) -> CLCircularRegion {
        let region = CLCircularRegion.init(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        
        region.notifyOnEntry = (geotification.eventType == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    func startMonitoring(geotification: Geotification) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle: "Error", message: "Geofencing is not supported on this device!")
            return
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showAlert(withTitle: "Warning", message: "Your geotification is saved but will only  be activated once you grant Geotify permission to access the device location")
            return
        }
        let region = self.region(withGeotification: geotification)
        locationManager.startMonitoring(for: region)
    }
    func stopMonitoring(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion,circularRegion.identifier == geotification.identifier else { return }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    // MARK: Map overlay functions
    func addRadiusOverlay(forGeotification geotification: Geotification) {
    
        mapView.add(MKCircle(center: geotification.coordinate, radius: geotification.radius), level: MKOverlayLevel.aboveRoads)
//        mapView?.add(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    func removeRadiusOverlay(forGeotification geotification: Geotification) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
                mapView?.remove(circleOverlay)
                break
            }
        }
    }
    func saveAllGeotifications() {
        var items: [Data] = []
        for geotification in geotifications {
            let item = NSKeyedArchiver.archivedData(withRootObject: geotification)
            items.append(item)
        }
        UserDefaults.standard.set(items, forKey: PreferenceKeys.savedItems)
    }
  
    func remove(geotification: Geotification) {
        if let indexInArray = geotifications.index(of: geotification) {
            geotifications.remove(at: indexInArray)
        }
        mapView.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
}
extension GeotificationsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Montioring failed for region with identifier:\(String(describing: region?.identifier))")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error:\(error)")
    }
}
extension GeotificationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         let identifier = "myGeotification"
        if annotation is Geotification {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton.init(type: .custom)
                removeButton.frame = CGRect.init(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(#imageLiteral(resourceName: "DeleteGeotification"), for: .normal)
            
                annotationView?.leftCalloutAccessoryView = removeButton
                annotationView?.pinTintColor = UIColor.init(named: "globalColor")
            }else {
                annotationView?.annotation = annotation
            }
            return annotationView
           
        }
        return nil
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let geotification = view.annotation as! Geotification
        remove(geotification: geotification)
        saveAllGeotifications()
    }
    //渲染overlay，设置圆周覆盖
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleView = MKCircleRenderer.init(overlay: overlay)
        circleView.strokeColor = UIColor.black.withAlphaComponent(0.5)
        circleView.lineWidth = 1
        circleView.fillColor = UIColor.lightGray.withAlphaComponent(0.4)
        return circleView
    }
    
}
extension GeotificationsViewController: AddGeotificationViewControllerDelegate {
    func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: EventType) {
        controller.dismiss(animated: true, completion: nil)
        
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geotification = Geotification.init(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
        
        self.add(geotification: geotification)
        startMonitoring(geotification: geotification)
        saveAllGeotifications()
    }
    
}
