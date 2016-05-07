//
//  ViewController.swift
//  MyUnimol
//
//  Created by Giovanni Grano on 09/02/16.
//  Copyright © 2016 Giovanni Grano. All rights reserved.
//

import UIKit
import Alamofire
import Gloss
import Charts

/**
 This class is the UIViewController for the home page of the application
 */
class ViewController: UIViewController {
    
    // the scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    // the circular progress bar
    @IBOutlet weak var progress: KDCircularProgress!
    // the label which contains the percentage value for the progress bar
    @IBOutlet weak var percentage: UILabel!
    // the line chart view
    @IBOutlet weak var lineChartView: LineChartView!
    // the bar chart view
    @IBOutlet weak var barChartView: BarChartView!
    // the average degree for all the exams
    @IBOutlet weak var average: UILabel!
    // the starting degree for your graduation
    @IBOutlet weak var startingDegree: UILabel!
    
    var recordBook: RecordBook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.setNavigationControllerStatusBar(self, title: "Home", color: Utils.myUnimolBlue, style: UIBarStyle.Black)
        
        
        let recordBook: RecordBookClass! = RecordBookClass.sharedInstance
        let grades = recordBook.recordBook?.examsGrades
        let degrees = recordBook.recordBook?.staringDegree
        
        self.average.text = "\(recordBook.recordBook!.average!)"
        self.startingDegree.text = "\((recordBook.recordBook?.average)! * 11 / 3)"
        print(degrees)
        
        
        let student = Student.sharedInstance
        let info = student.studentInfo
        print("\n*******", info!.department)
        print("\n*******", info!.course)

        self.animateButton()
        
        self.setGradesChart(grades!)
        self.setStartingDegreesChart(degrees!)
        
        
        //        if Utils.userAlreadyExists() {
        //            let (username, password) = Utils.getUsernameAndPassword()
        //
        //            let parameters = [
        //                "username" : username,
        //                "password" : password,
        //                "token"    : MyUnimolToken.TOKEN
        //            ]
        //
        //            Utils.progressBarDisplayer(self, msg: LoadSentences.getSentence(), indicator: true)
        //
        //            // Request
        //            Alamofire.request(.POST, MyUnimolEndPoints.GET_RECORD_BOOK, parameters: parameters)
        //                .responseJSON { response in
        //
        //                    Utils.removeProgressBar(self)
        //                    var statusCode : Int
        //                    if let httpError = response.result.error {
        //                        statusCode = httpError.code
        //                    } else {
        //                        statusCode = (response.response?.statusCode)!
        //                    }
        //
        //                    if statusCode == 200 {
        //
        //                        self.recordBook = RecordBook(json: response.result.value as! JSON)
        //                        let recordBookSingleton = RecordBookClass.sharedInstance
        //                        recordBookSingleton.recordBook = self.recordBook
        //
        //                        let recordBook: RecordBookClass! = RecordBookClass.sharedInstance
        //                        let grades = recordBook.recordBook?.examsGrades
        //                        let degrees = recordBook.recordBook?.staringDegree
        //
        //                        self.average.text = "\(recordBook.recordBook!.average!)"
        //                        self.startingDegree.text = "\((recordBook.recordBook?.average)! * 11 / 3)"
        //                        print(degrees)
        //
        //                        self.animateButton()
        //
        //                        self.setGradesChart(grades!)
        //                        self.setStartingDegreesChart(degrees!)
        //
        //                    } else if statusCode == 401 {
        //                        Utils.displayAlert(self, title: "Oops!", message: "Abbiamo qualche problema")
        //                    }
        //            }
        //        }
    }
    
    func setGradesChart(grades: [Int]) {
        self.lineChartView.noDataTextDescription = "Nessun esame verbalizzato"
        
        var dataEntries: [ChartDataEntry] = []
        
        var fakes = [String]()
        for i in 0..<grades.count {
            dataEntries.append(ChartDataEntry(value: Double(grades[i]), xIndex: i))
            fakes.append("")
        }
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Esami")
        lineChartDataSet.axisDependency = .Left
        lineChartDataSet.lineWidth = 1.0
        lineChartDataSet.circleRadius = 2.0
        lineChartDataSet.setDrawHighlightIndicators(false)
        lineChartDataSet.setColor(UIColor(CIColor: Utils.myUnimolBlue), alpha: 1.0)
        lineChartDataSet.setCircleColor(UIColor(CIColor: Utils.myUnimolBlue))
        
        let lineChartData = LineChartData(xVals: fakes, dataSet: lineChartDataSet)
        
        self.lineChartView.data = lineChartData
        self.lineChartView.data?.setValueTextColor(UIColor.clearColor()) // remove labels
        
        let rightAxis = self.lineChartView.getAxis(ChartYAxis.AxisDependency.Right)
        rightAxis.drawLabelsEnabled = false
        
        self.lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInBounce)
        
    }
    
    func setStartingDegreesChart(startingDegrees: [Int]) {
        self.barChartView.noDataTextDescription = "Nessun esame verbalizzato"
        self.barChartView.noDataText = "Non hai ancora esami a libretto"
        
        var dataEntries: [ChartDataEntry] = []
        
        var fakes = [String]()
        for i in 0..<startingDegrees.count {
            dataEntries.append(BarChartDataEntry(value: Double(startingDegrees[i]), xIndex: i))
            fakes.append("")
        }
        
        let barChartDataSet = BarChartDataSet(yVals: dataEntries, label: "Voto di partenza")
        barChartDataSet.axisDependency = .Left
        barChartDataSet.setColor(UIColor(CIColor: Utils.myUnimolBlue), alpha: 1.0)
        
        let barChartData = BarChartData(xVals: fakes, dataSet: barChartDataSet)
        
        self.barChartView.data = barChartData
        self.barChartView.data?.setValueTextColor(UIColor.clearColor())
        
        let rightAxis = self.barChartView.getAxis(ChartYAxis.AxisDependency.Right)
        rightAxis.drawLabelsEnabled = false
        
        self.barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInBounce)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateButton() {
        
        let totalCFU = RecordBookClass.sharedInstance.recordBook?.totalCFU
        let courseLenght = Student.sharedInstance.studentInfo?.courseLength
        
        var completeCFU: Int
        if courseLenght == 3 {
            completeCFU = 180
        } else {
            completeCFU = 120
        }
        
        var percentage = totalCFU! * 100 / completeCFU
        
        if (percentage > 100) { percentage = 100 }
        
        let angle = percentage * 360 / 100
        
        progress.animateFromAngle(0, toAngle: angle, duration: 1) { completed in
            if completed {
                self.percentage.text = "\(percentage)%"
            }
        }
    }
}


