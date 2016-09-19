//
//  LookupResultsViewController.swift
//  ComputerShowcase
//
//  Created by Wanag Xiaoming on 8/29/16.
//  Copyright © 2016 Wang Xiaoming. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2

class LookupResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtTitle: UILabel!
 
   
    
    var dataWithName: [[String]]?
    var submitData:[[String]]? = [[""]]
    var orders: [String]?
    var nameTitle : String = ""
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
         txtTitle.text = nameTitle + "'s Pre-Orders"

         btnSubmit.layer.cornerRadius = 5
         tableView.reloadData()
        
        let gesture = UITapGestureRecognizer(target: self, action: "backAction:")
        self.backView.addGestureRecognizer(gesture)
        
//        self.tableView.estimatedRowHeight = 220.0
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.reloadData()
        
        
        
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        
        return true
    }

    
    
    func backAction(sender:UITapGestureRecognizer){
        
        orders?.removeAll()
        dataWithName?.removeAll()
        self.navigationController!.popViewControllerAnimated(true)
    }
       
    // number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dataWithName! == [[""]] {
            return 0
        } else {
            return (self.orders?.count)!
        }
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var groupData: [[String]] = [[""]]
        
        let customCell : mainCustomCell = self.tableView.dequeueReusableCellWithIdentifier("mainCustomCell", forIndexPath: indexPath) as! mainCustomCell
        
        for row in dataWithName! {
            
            if row[3] == orders![indexPath.row] {
                if groupData == [[""]] {
                    groupData[0] = row
                } else{
                    groupData.append(row)
                }
            }
        }
        
        customCell.groupData = groupData
        customCell.tableView.reloadData()
        
        return customCell
        
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
//    {
//        
//        return UITableViewAutomaticDimension
//    }

//        func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//            return UITableViewAutomaticDimension
//        }
    
    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
   
    @IBAction func btnSubmitPressed(sender: AnyObject) {
        
        submitData?.removeAll()
        
        var index : Int = 0
        for order in orders! {
            
            let indexPath = NSIndexPath(forRow: index , inSection: 0)
            var customCell: mainCustomCell = tableView.cellForRowAtIndexPath(indexPath) as! mainCustomCell
            
            var subIndex: Int = 0
            for group in customCell.groupData! {
                
                let subIndexPath = NSIndexPath(forRow: subIndex , inSection: 0)
                var subCustomCell: childCustomCell = customCell.tableView.cellForRowAtIndexPath(subIndexPath)as!childCustomCell
                
                if subCustomCell.isChecked {
                    if customCell.groupData![subIndex].count < 10{
                        customCell.groupData![subIndex].append("2")
                    } else {
                        if customCell.groupData![subIndex][9] != "1" {
                            customCell.groupData![subIndex][9] = "2"
                        }
                        
                    }
                } else {
                    
                    if customCell.groupData![subIndex].count < 10{
                        customCell.groupData![subIndex].append("0")
                    } else {
                      customCell.groupData![subIndex][9] = "0"
                        
                    }

                }
                
                if self.submitData! == [[""]] {
                    self.submitData![0] = customCell.groupData![subIndex]
                } else {
                    self.submitData?.append(customCell.groupData![subIndex])
                }
                subIndex = subIndex + 1
            }
        
            index = index + 1
        }
        
        updateData()
        

        
    }
    
    func getCurrentTime() -> String{
        
        // get current time using Fomatter
        let date = NSDate();
        let formatter = NSDateFormatter();
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss";
        let defaultTimeZoneStr = formatter.stringFromDate(date);
        
        return defaultTimeZoneStr
    }
    
    func updateData() {
        
        let defaultTimeZoneStr = getCurrentTime()
        
        var i: Int = 0
        var index:Int = 0
        var updateData: [[String]] = [[""]]
        
        // initialize updateData
        for item in (sourceData.loadData)! {
            if updateData == [[""]] {
                updateData[0] = []
            } else {
                updateData.append([])
            }
            i = i + 1
        }
        
        // input into updateData
        for item in self.submitData! {
            
            var bufData :[String] = ["", "", "", ""]
            if item.count < 10 {
                
                bufData[0] = "0"
                bufData[2] = "0"
                
            } else {
                
                if item[9] == "2" {
                    
                    bufData[0] = "1"
                    bufData[1] = defaultTimeZoneStr
                    
                } else if item[9] == "0"{
                    bufData[0] = "0"
                    bufData[2] = "0"

                } else{
                    bufData = []
                }
                
            }
            
            
            updateData[Int(item[0])!] = bufData
           

            index = index + 1
        }
        
        // connect to google sheet and update data on google sheet
        let baseUrl = sourceData.baseUrl
        let spreadsheetId = sourceData.spreadsheetId
        let range = "Live!I2:L"
        let url = String(format:"%@/%@/values/%@", baseUrl, spreadsheetId, range)
        let params = ["valueInputOption":"USER_ENTERED"]
        let fullUrl = GTLUtilities.URLWithString(url, queryParameters: params)
        
        
        let body = GTLObject()
        body.setJSONValue("Live!I2:L", forKey: "range")
        body.setJSONValue("ROWS", forKey: "majorDimension")
        body.setJSONValue(updateData , forKey: "values")
        
        // show the log of body oject
        print(body)
        
        sourceData.service.fetchObjectByUpdatingObject(body,
                                            forURL: fullUrl,
                                            delegate: self,
                                            didFinishSelector: "displayResultWithTicket:finishedWithObject:error:")    }
    
    
    // Process the response and display output
    func displayResultWithTicket(ticket: GTLServiceTicket,
                                 finishedWithObject object : GTLObject,
                                                    error : NSError?) {
        
        if error == nil {
            
            orders?.removeAll()
            dataWithName?.removeAll()
            self.navigationController!.popViewControllerAnimated(true)
        }
        
    
    }

    
    
    
    
}
