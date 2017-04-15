//
//  FirstPageController.swift
//  MyUnimol
//
//  Created by Giovanni Grano on 01/05/16.
//  Copyright © 2016 Giovanni Grano. All rights reserved.
//

import UIKit
import Alamofire
import Gloss

class FirstPageController: UIViewController {

    var goToLoginPage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Reachability.isConnectedToNetwork() {
            // no connection available
            CacheManager.sharedInstance.getJsonByString(CacheManager.STUDENT_INFO) { json in
                if (json != nil) {
                    Student.sharedInstance.studentInfo = StudentInfo(json: json!)
                } else {
                    self.showErrorAndGoToLogin()
                }
                CacheManager.sharedInstance.getJsonByString(CacheManager.RECORD_BOOK) { json in
                    if (json != nil) {
                        RecordBookClass.sharedInstance.recordBook = RecordBook(json: json!)
                        self.performSegue(withIdentifier: "ViewController", sender: self)
                    } else {
                        self.showErrorAndGoToLogin()
                    }
                }
            }
        } else {
            self.loginAndGetStudentInfo()
        }
    }
    
    func loginAndGetStudentInfo() {
        StudentInfo.getCredentials { studentInfo in
            guard studentInfo != nil else {
                self.showErrorAndGoToLogin()
                return
            }
            if studentInfo!.areCredentialsValid {
                self.getRecordBook()
            } else {
                // login not valid
                Utils.displayAlert(self, title: "Ops 😨", message: "Credenziali non valide!")
                CacheManager.sharedInstance.resetCredentials()
                CacheManager.sharedInstance.refreshCache()
                Utils.goToLogin()
                return
            }
        }
    }
    
    func getRecordBook() {
        RecordBook.getRecordBook { recordBook in
            guard recordBook != nil else {
                self.showErrorAndGoToLogin()
                return
            }
            self.performSegue(withIdentifier: "ViewController", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let centerViewContainer = appDelegate.mainStoryBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let centerNav = UINavigationController(rootViewController: centerViewContainer)
        
        appDelegate.centerContainer!.centerViewController = centerNav
        appDelegate.centerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.panningCenterView
    }
    
    /// Showed when an API strange error occurs; shows an alert dialog and returns to login page
    fileprivate func showErrorAndGoToLogin() {
        Utils.displayAlert(self, title: "😨 Ooopss...", message: "Qualcosa è andato 👎 ma non saprei proprio cosa ☹️! Ritenta tra poco 💪")
        CacheManager.sharedInstance.resetCredentials()
        CacheManager.sharedInstance.refreshCache()
        Utils.goToLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
