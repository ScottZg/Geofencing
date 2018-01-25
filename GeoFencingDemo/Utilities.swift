//
//  Utilities.swift
//  GeoFencingDemo
//
//  Created by zhanggui on 2018/1/23.
//  Copyright © 2018年 zhanggui. All rights reserved.
//

import UIKit
import MapKit

extension UIViewController {
    func showAlert(withTitle title:String? ,message: String?) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
extension MKMapView {
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else {
            return
        }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 0.1, 0.1)
        setRegion(region, animated: true)
        
    }
}
