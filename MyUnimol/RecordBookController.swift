//
//  RecordBookController.swift
//  MyUnimol
//
//  Created by Giovanni Grano on 28/02/16.
//  Copyright © 2016 Giovanni Grano. All rights reserved.
//

import UIKit
import Alamofire
import Gloss

class RecordBookController: UIViewController, UITableViewDelegate {

    var recordBook: RecordBookClass!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.recordBook = RecordBookClass.sharedInstance
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordBook.recordBook!.exams.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordBookCell", forIndexPath: indexPath) as! RecordBookCell
        
        let currentRecordBook = self.recordBook.recordBook?.exams[indexPath.row]
        cell.examName.text = currentRecordBook!.name
        cell.grade.text = currentRecordBook!.vote
        cell.cfu.text = "\(currentRecordBook!.cfu!)"
        cell.date.text = currentRecordBook!.date
                
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}
