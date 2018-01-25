//
//  AppDelegate.swift
//  GeoFencingDemo
//
//  Created by zhanggui on 2018/1/23.
//  Copyright © 2018年 zhanggui. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?

    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        let currentNotificationCenter = UNUserNotificationCenter.current()
        currentNotificationCenter.delegate = self
        currentNotificationCenter.requestAuthorization(options: [.alert,.sound,.badge]) { (boo, error) in
         
            if boo {
                print("允许推送")
            }
        }
        currentNotificationCenter.getNotificationSettings { (settings) in
            print("settings")
        }
        return true
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    //MARK: prviate method
    func handleEvent(forRegion region: CLRegion!) {
        if UIApplication.shared.applicationState == .active {
            guard let message = note(fromRegionIdentifier: region.identifier) else { return }
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
        }else {
            let content = UNMutableNotificationContent()
            content.title = "提醒"
            content.body = note(fromRegionIdentifier: region.identifier)!
            content.sound = UNNotificationSound.init(named: "warning.caf")
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest.init(identifier: "notification.id.01", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    func note(fromRegionIdentifier identifier: String) -> String? {
        let savedItems = UserDefaults.standard.array(forKey: PreferenceKeys.savedItems) as? [NSData]
        let geotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? Geotification }
        let index = geotifications?.index { $0?.identifier == identifier }
        return index != nil ? geotifications?[index!]?.note : nil
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("Enter Region")
            handleEvent(forRegion: region)
        }
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("Exit Region")
            handleEvent(forRegion: region)
        }
    }
}
