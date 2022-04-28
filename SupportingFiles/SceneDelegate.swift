//
//  SceneDelegate.swift
//  TripReminder
//
//  Created by Linda adel on 12/20/21.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var storyBoard : UIStoryboard?
    var rootViewController : UIViewController?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        //initialize window
        self.window = UIWindow(windowScene: windowScene)
        //initialize main storyboard
       storyBoard = UIStoryboard(name: "Main", bundle: nil)
        //check getstarted state in userdeafult
        if (UserDefaults.standard.bool(forKey: "login")) {
            rootViewController = storyBoard?.instantiateViewController(identifier: "login") as? LogInViewController
        }else {
            //check if user already signed in
            if Auth.auth().currentUser != nil
            {
               
            // check if user is signed in open home screen
            rootViewController = storyBoard?.instantiateViewController(identifier: "homeCalender") as? CalenderHomeViewController
            }else {
                rootViewController = storyBoard?.instantiateViewController(withIdentifier: "login")as! LogInViewController
               
            }
        }
        //set initial view controller
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

