//
//  AddGeotificationViewController.swift
//  GeoFencingDemo
//
//  Created by zhanggui on 2018/1/23.
//  Copyright © 2018年 zhanggui. All rights reserved.
//

import UIKit
import MapKit

protocol AddGeotificationViewControllerDelegate {
    func addGeotificationViewController(controller: AddGeotificationViewController,didAddCoordinate coordinate: CLLocationCoordinate2D,radius: Double,identifier: String,note: String,eventType: EventType)
}

class AddGeotificationViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var zooButton: UIBarButtonItem!
    @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var rediusTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    var delegate: AddGeotificationViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.isEnabled = false
        mapView.userTrackingMode = .follow
    }
    @IBAction func closeAddViewAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
  
    @IBAction func onZoomToCurrentLocation(_ sender: Any) {
        mapView.zoomToUserLocation()
    }
    @IBAction func onAdd(_ sender: Any) {
        
        let coordinate  = mapView.centerCoordinate
        let radius = Double(rediusTextField.text!) ?? 0
        let identifier = NSUUID().uuidString   //每次生成唯一标识来标注该geotification
        print(identifier)
        let note = noteTextField.text
        let eventType: EventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? .onEntry : .onExit
        
        delegate?.addGeotificationViewController(controller: self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note!, eventType: eventType)
    }
    


}
extension AddGeotificationViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        addButton.isEnabled = !rediusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
    }
}
