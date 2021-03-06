//
//  AppDelegate.swift
//  Tobydi
//
//  Created by Muhammad Abdullah on 11/01/2019.
//  Copyright © 2019 Muhammad Abdullah. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import SVProgressHUD
import GoogleMobileAds
import Reachability
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var interstitial: GADInterstitial!

    var window: UIWindow?
    let reachability = Reachability()!

    func showInterstitial(_ notification: NSNotification) {
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4401604271141178/8098469764")
        let request = GADRequest()
        interstitial.delegate = (self as! GADInterstitialDelegate)
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        //request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9b" ]
        interstitial.load(request)
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        
        if(self.interstitial.isReady){
            interstitial.present(fromRootViewController: (self.window?.rootViewController)!)
            
        }
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        NSLog("")
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if (reachability.connection == .wifi) || (reachability.connection == .cellular){
            
        }
        else{
            let alert = UIAlertController(title: "Error in Connection", message: "check your internet connection", preferredStyle: .actionSheet)
            //alert.showToast(message: "check your internet connection")
            alert.view.backgroundColor = UIColor.white
            
            let LabelView = UILabel(frame: CGRect(x:0, y: alert.view.frame.height/2, width: alert.view.frame.width, height: 100))
            LabelView.text = reachability.connection.description
            LabelView.textAlignment = .center
            LabelView.font = UIFont(name: "Avenir", size: 40.0)
            alert.view.addSubview(LabelView)
            SVProgressHUD.showError(withStatus: reachability.connection.description)
            //SVProgressHUD.show(withStatus: "Waiting for internet...")
            self.window?.rootViewController = alert
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = alert
            self.window?.makeKeyAndVisible()

        }

        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
        
        GADMobileAds.configure(withApplicationID: "Pub-4401604271141178")

        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
   
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Tobydi")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

