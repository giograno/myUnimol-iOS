//
//  ApiCall.swift
//  MyUnimol
//
//  Created by Giovanni Grano on 18/03/16.
//  Copyright © 2016 Giovanni Grano. All rights reserved.
//


import UIKit
import Alamofire
import Gloss

/**
 A class which contains all static methods used to query the services from web server
 */
class ApiCall {
    
    /**
     Checks the network availability
     */
    static func isConnectionAvailable() -> Bool {
        return Reachability.isConnectedToNetwork()
    }
    
    /**
     Checks for credentials stored in `NSUserDefaults`
     - returns: a boolean value
     */
    static func areCredentialsStored() -> Bool {
        let (username, password) = CacheManager.getUserCredential()
        
        if (username == nil && password == nil) {
            return false
        } else {
            return true
        }
    }
    
    static func areCredentialsValid(username: String, password: String, caller: UIViewController) {
        
        let parameters = [
            "username"  : username,
            "password"  : password,
            "token"     : MyUnimolToken.TOKEN
        ]
        
        Utils.progressBarDisplayer(caller, msg: LoadSentences.getSentence(), indicator: true)
        
        Alamofire.request(.POST, MyUnimolEndPoints.TEST_CREDENTIALS, parameters: parameters)
            .responseJSON {response in
                
                Utils.removeProgressBar(caller)
                
                var statusCode: Int
                if let httpError = response.result.error {
                    statusCode = httpError.code
                } else {
                    statusCode = (response.response?.statusCode)!
                }
                print(statusCode)
                if (statusCode == 200) {
                    // store gathered data into the singleton
                    let student = Student.sharedInstance
                    let json = response.result.value as! JSON
                    student.studentInfo = StudentInfo(json: json)
                    
                    // put the data into the cache
                    CacheManager.storeLoginInformation(username, password: password)
                    CacheManager.storeJsonInCacheByKey(CacheManager.STUDENT_INFO_KEY, json: json)
                    
                    // segue to home page
                    caller.performSegueWithIdentifier("ViewController", sender: self)
                } else if (statusCode == 401) {
                    // credentials not valid
                    Utils.displayAlert(caller, title: "Oops!", message: "I tuoi dati di accesso sembrano errati")
                }
        }
    }
    
    static func loginAndFetchDataForHome(username: String, password: String, caller: UIViewController) {
        
        let parameters = [
            "username"  : username,
            "password"  : password,
            "token"     : MyUnimolToken.TOKEN
        ]
        
        Utils.progressBarDisplayer(caller, msg: LoadSentences.getSentence(), indicator: true)
        
        Alamofire.request(.POST, MyUnimolEndPoints.TEST_CREDENTIALS, parameters: parameters)
            .responseJSON {response in
                
                var statusCode: Int
                if let httpError = response.result.error {
                    statusCode = httpError.code
                } else {
                    statusCode = (response.response?.statusCode)!
                }
                print(statusCode)
                if (statusCode == 200) {
                    // store gathered data into the singleton
                    let student = Student.sharedInstance
                    let json = response.result.value as! JSON
                    student.studentInfo = StudentInfo(json: json)
                    
                    // put the data into the cache
                    CacheManager.storeLoginInformation(username, password: password)
                    CacheManager.storeJsonInCacheByKey(CacheManager.STUDENT_INFO_KEY, json: json)
                    
                    // also fetch data for Home Page
                    fetchDataForHome(username, password: password, caller: caller)
                    
                } else if (statusCode == 401) {
                    // credentials not valid
                    Utils.displayAlert(caller, title: "Oops!", message: "I tuoi dati di accesso sembrano errati")
                }
        }
    }
    
    static func fetchDataForHome(username: String, password: String, caller: UIViewController) {
        
        let parameters = [
            "username"  : username,
            "password"  : password,
            "token"     : MyUnimolToken.TOKEN
        ]
        
        Alamofire.request(.POST, MyUnimolEndPoints.GET_RECORD_BOOK, parameters: parameters)
            .responseJSON { response in
                
                Utils.removeProgressBar(caller)
                var statusCode : Int
                if let httpError = response.result.error {
                    statusCode = httpError.code
                } else {
                    statusCode = (response.response?.statusCode)!
                }
                
                if statusCode == 200 {
                    
                    // put the record book in singleton
                    let recordBook = RecordBook(json: response.result.value as! JSON)
                    let recordBookSingleton = RecordBookClass.sharedInstance
                    recordBookSingleton.recordBook = recordBook
                    
                    //TODO: implement cache management
                    
                    // segue to home page
                    caller.performSegueWithIdentifier("ViewController", sender: self)
                } else if statusCode == 401 {
                    Utils.displayAlert(caller, title: "Oops!", message: "Abbiamo qualche problema")
                }
        }
    }
    
    
    /**
     Call the getTaxes service from server, instantiating the TaxClass singleton.
     Update the asyncronous the table passed as parameter
     
     - parameter calling: the UIViewController that send the request
     - parameter table: the table to update
     */
    static func getTaxes(calling: UIViewController, table: UITableView) {
        
        let (username, password) = CacheManager.getUserCredential()
        
        let parameters = [
            "username" : username!,
            "password" : password!,
            "token"    : MyUnimolToken.TOKEN
        ]
        
        Utils.progressBarDisplayer(calling, msg: LoadSentences.getSentence(), indicator: true)
        
        Alamofire.request(.POST, MyUnimolEndPoints.GET_TAXES, parameters: parameters)
            .responseJSON { response in
                
                Utils.removeProgressBar(calling)
                
                var statusCode : Int
                if let httpError = response.result.error {
                    statusCode = httpError.code
                } else {
                    statusCode = (response.response?.statusCode)!
                }
                
                print("Calling getTaxes! The response from server is: \(statusCode)")
                
                if (statusCode == 200) {
                    
                    let taxesSingleton = TaxClass.sharedInstance
                    taxesSingleton.taxes = Taxes(json: response.result.value as! JSON)
                    
                } else if (statusCode == 401) {
                    
                    Utils.displayAlert(calling, title: "Oops!", message: "Qualcosa di strano è successo")
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    table.reloadData()
                    table.hidden = false
                })
        }
    }
    
    static func getAvailableExams(calling: UIViewController, table: UITableView) {
        
        var isEmpty = false
        let (username, password) = CacheManager.getUserCredential()
        
        let parameters = [
            "username" : username!,
            "password" : password!,
            "token"    : MyUnimolToken.TOKEN
        ]
        
        Utils.progressBarDisplayer(calling, msg: LoadSentences.getSentence(), indicator: true)
        
        Alamofire.request(.POST, MyUnimolEndPoints.GET_EXAM_SESSIONS, parameters: parameters)
            .responseJSON { response in
                
                Utils.removeProgressBar(calling)
                
                var statusCode : Int
                if let httpError = response.result.error {
                    statusCode = httpError.code
                } else {
                    statusCode = (response.response?.statusCode)!
                }
                
                print("Calling getAvailableExams! The response from server is: \(statusCode)")
                
                if (statusCode == 200) {
                    
                    let availableExams = ExamsClass.sharedInstance
                    availableExams.exams = ExamSessionList(json: response.result.value as! JSON)
                    
                    if(availableExams.exams?.examsList.count == 0) {
                        isEmpty = true
                    }
                    
                } else if (statusCode == 401) {
                    Utils.displayAlert(calling, title: "Oops!", message: "Qualcosa di strano è successo")
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    if isEmpty {
                        table.hidden = true
                        Utils.setPlaceholderForEmptyTable(calling, message: "Non ci sono appelli disponibili")
                    } else {
                        table.reloadData()
                        table.hidden = false
                    }
                })
        }
    }
    
    static func getEnrolledExams(calling: UIViewController, table: UITableView) {
        
        var isEmpty: Bool = false
        
        let (username, password) = CacheManager.getUserCredential()
        
        let parameters = [
            "username" : username!,
            "password" : password!,
            "token"    : MyUnimolToken.TOKEN
        ]
        
        Utils.progressBarDisplayer(calling, msg: LoadSentences.getSentence(), indicator: true)
        
        Alamofire.request(.POST, MyUnimolEndPoints.GET_ENROLLED_EXAMS, parameters: parameters)
            .responseJSON { response in
                
                Utils.removeProgressBar(calling)
                
                var statusCode : Int
                if let httpError = response.result.error {
                    statusCode = httpError.code
                } else {
                    statusCode = (response.response?.statusCode)!
                }
                
                print("Calling getEnrolledExams! The response from server is: \(statusCode)")
                
                if (statusCode == 200) {
                    
                    let enrolledExams = EnrolledExamsClass.sharedInstance
                    enrolledExams.exams = EnrolledExamsList(json: response.result.value as! JSON)
                    
                    if(enrolledExams.exams?.examsList.count == 0) {
                        isEmpty = true
                    }
                    
                } else if (statusCode == 401) {
                    Utils.displayAlert(calling, title: "Oops!", message: "Qualcosa di strano è successo")
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    if (isEmpty) {
                        table.hidden = true
                        Utils.setPlaceholderForEmptyTable(calling, message: "Non ci sono appelli prenotati")
                    } else {
                        table.reloadData()
                        table.hidden = false
                    }
                })
        }
    }
}

