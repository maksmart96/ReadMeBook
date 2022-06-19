//
//  AppDelegate.swift
//  ReadMe
//
//  Created by  Максим Мартынов on 19.03.2022.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    //MARK: - Core Data Stack - PersistentStore
    
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "LibraryModel")
//        container.loadPersistentStores { description, error in
//            if let error = error as NSError? {
//              fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//        return container
//    }()
}

