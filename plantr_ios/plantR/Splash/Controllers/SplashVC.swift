//
//  SplashVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 31/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase

class SplashVC: UIViewController {
    @IBOutlet var bg: UIImageView!
    
    enum Consts {
        static let GoToHomeNotification = "GoToHomeNotification"
    }
    
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var plantsService: PlantsService!
    
    private var isListening = false
    private var gardenersMetadataRef: DatabaseQuery!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(goToHome), name: Notification.Name(rawValue: Consts.GoToHomeNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !UserService.shared.splashFirstLoad else { return }
        UserService.shared.splashFirstLoad = true
        //                try! Auth.auth().signOut()
        
        
        print(Auth.auth().currentUser)
        var test = Auth.auth().addStateDidChangeListener { auth, user in
            
            print("-----------------------------")
            print(auth.currentUser)
            print(user)
            print(user?.isAnonymous)
            print(user?.uid)
            print(user?.email)
            print("-----------------------------")
            
            if self.presentedViewController != nil {
                self.dismiss(animated: true, completion: nil)
            }
            
            guard let user = user else {
                self.perform(segue: StoryboardSegue.Splash.goToLogin)
                return
            }
            
            self.userRepository.getReference(for: user.uid).observeSingleEvent(of: .value, with: { snapGood in
                if (!snapGood.exists()) {
                    self.perform(segue: StoryboardSegue.Splash.goToLogin)
                } else {
                    self.plantsService.refreshService()
                    self.userRepository.getGardenersReference(for: user.uid).observeSingleEvent(of: .value, with: { snap in
                        if snap.exists() {
                            self.userRepository.getReference(for: user.uid).observeSingleEvent(of: .value, with: { snapExist in
                                var userModel = self.userTransformer.toUserModel(snap: snapExist)
                                if (userModel.gardeners.contains(userModel.currentGardener)) {
                                    self.perform(segue: StoryboardSegue.Splash.goToHome)
                                } else {
                                    if (userModel.gardeners.count <= 0) {
                                        self.perform(segue: StoryboardSegue.Splash.goToHome)
                                    } else {
                                        var firstGardenerInList = userModel.gardeners.first
                                        self.userRepository.getCurrentGardenerReference(for: user.uid).setValue(firstGardenerInList, withCompletionBlock: { (authResult, error) in
                                            self.perform(segue: StoryboardSegue.Splash.goToHome)
                                        })
                                    }
                                }
                            })
                        } else {
                            self.userRepository.getCurrentGardenerReference(for: user.uid).setValue("") { _,_  in
                                self.perform(segue: StoryboardSegue.Splash.goToHome)
                            }
                        }
                        
                    })
                }
                
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc private func goToHome() {
        if self.presentedViewController != nil {
            self.dismiss(animated: true, completion: nil)
            self.perform(segue: StoryboardSegue.Splash.goToHome)
        }
    }
}
