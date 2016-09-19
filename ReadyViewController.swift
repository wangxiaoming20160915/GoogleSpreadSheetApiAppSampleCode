//
//  LookupResultsViewController.swift
//  ComputerShowcase
//
//  Created by Wanag Xiaoming on 8/29/16.
//  Copyright © 2016 Wanag Xiaoming. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2

class ReadyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtTitle: UILabel!
    
    var isBtnSubmitClick: Bool = false
    
    var titleTxt: String?
    var dataWithName: [[String]]=[[""]]
    var orders: [String]=[""]
    var submitData:[[String]]? = [[""]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataWithName = self.getDataWithName(titleTxt!)
        
        txtTitle.text = titleTxt! + "'s Ready for Pick-Up"
        
        let gesture = UITapGestureRecognizer(target: self, action: "backAction:")
        self.backView.addGestureRecognizer(gesture)

        
        btnSubmit.layer.cornerRadius = 5

        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.reloadData()
        
        self.getUploadDataWhenAppear()
        
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    func backAction(sender:UITapGestureRecognizer){
        self.navigationController!.popViewControllerAnimated(true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    // number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataWithName == [[""]] {
            return 0
        } else {
            return (self.orders.count)
        }

    }
    
      
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let customCell : mainCustomCell2 = self.tableView.dequeueReusableCellWithIdentifier("mainCustomCell2", forIndexPath: indexPath) as! mainCustomCell2
        var groupData: [[String]] = [[""]]
        
        for row in dataWithName {
            
            if row[3] == orders[indexPath.row] {
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
        //        let menuVC = "page3"
        //
        //        let viewController = storyboard?.instantiateViewControllerWithIdentifier(menuVC) as! Page3ViewController
        //        viewController.titleStr = titleStr + " " + nameArray[indexPath.row]
        //        viewController.rootTitle = titleStr
        //        viewController.nameTitle = nameArray[indexPath.row]
        //        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func getUploadDataWhenAppear(){
        
        let defaultTimeZoneStr = getCurrentTime()
        
        var i: Int = 0
        var updateData: [[String!]] = [[""]]
        
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
        var bufDataWithName:[[String]] = [[""]]
        for var item in self.dataWithName {
            
            var bufData :[String!] = ["1", defaultTimeZoneStr ,"0", ""]
            if item.count > 12 {
                bufData[3] = item[12]
            } else {
                bufData[3] = ""
                
            }
            
            item[9] = "1"
            item[10] = defaultTimeZoneStr
            item[11] = "0"
        
            
            updateData[Int(item[0])!] = bufData
            sourceData.loadData![Int(item[0])!][9] = "1"
            sourceData.loadData![Int(item[0])!][10] = defaultTimeZoneStr
            sourceData.loadData![Int(item[0])!][11] = "0"
            
            if bufDataWithName == [[""]] {
                bufDataWithName[0] = item
            } else{
                bufDataWithName.append(item)
            }
            
        }
       
        dataWithName = bufDataWithName
        self.tableView.reloadData()
        requestUpdate(updateData)

    }

    
    @IBAction func btnSubmitPressed(sender: AnyObject) {
        
        isBtnSubmitClick = true
        
        submitData?.removeAll()
        
        var index : Int = 0
        for order in orders {
            
            let indexPath = NSIndexPath(forRow: index , inSection: 0)
            var customCell: mainCustomCell2 = tableView.cellForRowAtIndexPath(indexPath) as! mainCustomCell2
            
            var subIndex: Int = 0
            for group in customCell.groupData! {
                
                let subIndexPath = NSIndexPath(forRow: subIndex , inSection: 0)
                var subCustomCell: childCustomCell2 = customCell.tableView.cellForRowAtIndexPath(subIndexPath)as!childCustomCell2
                
                if subCustomCell.isChecked {
                    if customCell.groupData![subIndex].count < 12{
                        customCell.groupData![subIndex].append("2")
                    } else {
                        if customCell.groupData![subIndex][11] != "1" {
                            customCell.groupData![subIndex][11] = "2"
                        }
                        
                    }
                } else {
                    
                    if customCell.groupData![subIndex].count < 12{
                        customCell.groupData![subIndex].append("0")
                    } else {
                        customCell.groupData![subIndex][11] = "0"
                        
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
        var updateData: [[String!]] = [[""]]
        
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
            
            var bufData :[String!] = [nil, "", "", ""]
            if item.count < 12 {
                bufData[2] = "0"
                bufData[0] = item[9]
                bufData[1] = item[10]
                bufData[3] = ""
            } else {
                
                if item[11] == "2" {
                    
                    bufData[2] = "1"
                    bufData[3] = defaultTimeZoneStr
                    bufData[0] = item[9]
                    bufData[1] = item[10]
                    
                } else if item[11] == "0"{
                    bufData[2] = "0"
                    bufData[0] = item[9]
                    bufData[1] = item[10]
                    bufData[3] = ""
                    
                } else{
                    bufData = []
                }
                
            }
            
            updateData[Int(item[0])!] = bufData
            
            index = index + 1
        }
        
        requestUpdate(updateData)
        
   }
    
    
    func requestUpdate(updateData:[[String!]]){
        
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
                                                       didFinishSelector: "displayResultWithTicket:finishedWithObject:error:")
    }
    
    // Process the response and display output
    func displayResultWithTicket(ticket: GTLServiceTicket,
                                 finishedWithObject object : GTLObject,
                                                    error : NSError?) {
        
        if error == nil {
            if isBtnSubmitClick {
                self.navigationController!.popViewControllerAnimated(true)
                isBtnSubmitClick = false
            }
            
        }
        
        
    }

    
    func getDataWithName(accountName:String) -> [[String]]
    {
        
        var isExistSameOrder: Bool = false
        
        var dataWithAccountName: [[String]] = [[""]]
        
        if sourceData.loadData != nil {
            
            for row in sourceData.loadData! {
                
                isExistSameOrder = false
                
                let name = row[2]
                if name == accountName {
                    
                    // get orders
                    if orders == [""] {
                        
                        orders[0] = row[3]
                        
                    } else {
                        
                        for order in orders {
                            
                            if order == row[3] {
                                isExistSameOrder = true
                            }
                        }
                        
                        if !isExistSameOrder {
                            orders.append(row[3])
                        }
                        
                    }
                    
                    // add the record into dataWithAccountName
                    if dataWithAccountName == [[""]] {
                        dataWithAccountName[0] = row
                    } else{
                        dataWithAccountName.append(row)
                    }
                    
                }
                
                
            }
        }
        
        return dataWithAccountName
        
    }
    
    

    
}
