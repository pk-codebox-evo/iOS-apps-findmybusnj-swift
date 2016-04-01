//
//  AppDelegate.swift
//  findmybusnj
//
//  Created by David Aghassi on 9/28/15.
//  Copyright © 2015 David Aghassi. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var shortcutItemManager: ThreeDTouchCoreDataManager!
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    shortcutItemManager = ThreeDTouchCoreDataManager(managedObjectContext: self.managedObjectContext)
    // Override point for customization after application launch.
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    let fetchRequest = NSFetchRequest(entityName: "Favorite")
    var favorites = shortcutItemManager.attemptFetch(fetchRequest)
    favorites = shortcutItemManager.sortDescending(favorites)
    var shortcutItem: UIApplicationShortcutItem
    
    /**
     *  TODO - Remove all prior favorites
     */
    
    for i in 0..<3 {
      let currentFavorite = favorites[i] as! Favorite
      guard let type = NSBundle.mainBundle().bundleIdentifier else {
        return
      }
      guard let title = currentFavorite.stop else {
        return
      }
      guard let subtitle = currentFavorite.route else {
        return
      }
      
      if #available(iOS 9.1, *) {
        shortcutItem = UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: subtitle, icon: UIApplicationShortcutIcon(type: .Favorite), userInfo: nil)
      } else {
        // Fallback on earlier versions
        shortcutItem = UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: subtitle, icon: UIApplicationShortcutIcon(type: .Search), userInfo: nil)
      }
      
      UIApplication.sharedApplication().shortcutItems?.insert(shortcutItem, atIndex: 0)
    }
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }
  
  // MARK: - 3D Touch
  func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
    completionHandler(handleShortcut(shortcutItem))
  }
  
  /**
   Handles displaying the 3D Touch Shortcut Selected
   
   - parameter shortcut: The `UIApplicationShortcutItem` selected
   
   - returns: True if the selection is handled, false otherwise
   */
  private func handleShortcut(shortcut: UIApplicationShortcutItem) -> Bool {
    let shortcutType = shortcut.type
    guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: shortcutType) else {
      return false
    }
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    switch shortcutIdentifier {
      case ShortcutIdentifier.openSearch:
        let searchPopover = storyboard.instantiateViewControllerWithIdentifier("ETASearchPopOverController")
        let root = UIApplication.sharedApplication().keyWindow?.rootViewController
        root?.presentViewController(searchPopover, animated: true, completion: nil)
        
        return true
      case ShortcutIdentifier.findFavorite:
        return true
    }
  }
  
  
  // MARK: - Core Data stack
  lazy var applicationDocumentsDirectory: NSURL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "aghassi.findmybusnj" in the application's documents Application Support directory.
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1]
  }()
  
  lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let modelURL = NSBundle.mainBundle().URLForResource("FindMyBusCoreDataModel", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    } catch {
      // Report any error we got.
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      
      dict[NSUnderlyingErrorKey] = error as NSError
      let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      // Replace this with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
      abort()
    }
    
    return coordinator
  }()
  
  lazy var managedObjectContext: NSManagedObjectContext = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()
  
  // MARK: - Core Data Saving support
  func saveContext () {
    if managedObjectContext.hasChanges {
      do {
        try managedObjectContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
      }
    }
  }
}

