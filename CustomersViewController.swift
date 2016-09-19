//
//  CustomersViewController.swift
//  ComputerShowcase
//
//  Created by Wanag Xiaoming on 8/29/16.
//  Copyright © 2016 Wanag Xiaoming. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2

class CustomersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var accounts: [String] = [""]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let gesture = UITapGestureRecognizer(target: self, action: "backAction:")
        self.backView.addGestureRecognizer(gesture)
        
    
        // interval calling
        var updateTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "listMajors", userInfo: nil, repeats: true)
         tableviewHeight.constant = 44 * 5
        
        tableView.reloadData()
        
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        listMajors()
        
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
        
        if accounts == [""] {
            return 0
        } else {
            return (accounts.count)
        }
       
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let customCell : customerCustomCell = self.tableView.dequeueReusableCellWithIdentifier("customerCustomCell", forIndexPath: indexPath) as! customerCustomCell
        customCell.customerName.text = accounts[indexPath.row] 
        customCell.accounts = self.accounts
        customCell.index = indexPath.row
        customCell.SelfViewController = self.navigationController
        return customCell
    }
    
    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func listMajors() {
        
        let baseUrl = sourceData.baseUrl
        let spreadsheetId = sourceData.spreadsheetId
        let range = sourceData.wholeRange
        let url = String(format:"%@/%@/values/%@", baseUrl, spreadsheetId, range)
        let params = ["majorDimension": "ROWS"]
        let fullUrl = GTLUtilities.URLWithString(url, queryParameters: params)
        sourceData.service.fetchObjectWithURL(fullUrl,
                                   objectClass: GTLObject.self,
                                   delegate: self,
                                   didFinishSelector: "displayResultWithTicket:finishedWithObject:error:"
            
            
        )
    }
    
    
    // Process the response and display output
    func displayResultWithTicket(ticket: GTLServiceTicket,
                                 finishedWithObject object : GTLObject,
                                                    error : NSError?) {
        
        
        var majorsString = ""
        var rows = object.JSON["values"] as! [[String]]
        
        
        var bufRows: [[String]] = [[""]]
        majorsString += "Name, Major:\n"
        var number: Int = 0
        for var row in rows {
            var numberString: String = String(number)
            row.insert(numberString, atIndex: 0)
            
            if bufRows ==  [[""]]{
                bufRows[0] = row
            }
            bufRows.append(row)
            
            number = number + 1
        }
        
        sourceData.loadData = bufRows
        sourceData.loadData?.removeAtIndex(0)
        getAccounts()
        tableView.reloadData()
        
    }
    
    func getAccounts(){
        
        self.sortDataWithPIckupTimestamp()
        
        accounts.removeAll()
        
        var isExistSameAccount: Bool = false
        
        if sourceData.loadData != nil {
            
            for row in sourceData.loadData! {
                if row[2] != "" {
                    
                    if accounts == [""] {
                        accounts[0] = row[2]
                    }
                    
                    
                    isExistSameAccount = false
                    
                    // get the accounts
                    for account in accounts {
                        
                        if account == row[2] {
                            isExistSameAccount = true
                        }
                        
                    }
                    
                    if !isExistSameAccount {
                        if accounts == [""] {
                            accounts[0] = row[2]
                        } else {
                          accounts.append(row[2])
                        }
                        
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
    func sortDataWithPIckupTimestamp() {
        
        var bufferItem: [String]?
        var bufData: [[String]] = sourceData.loadData!
        
        for var i = (bufData.count - 1); i > 0; i -= 1 {
            
            for j in 1 ..< i {
                
                let itemDate = convertDateStringToNSDate(bufData[j][10])
                let itemDate2 = convertDateStringToNSDate(bufData[j-1][10])
                
                if itemDate2 > itemDate {
                    bufferItem = bufData[j-1]
                    bufData[j-1] = bufData[j]
                    bufData[j] = bufferItem!
                }
                
            }
            
        }
        
        sourceData.loadData = bufData
        
    }
    
    func convertDateStringToNSDate(date:String) -> Int64 {
    
        if date == "" {
            
            return 100
            
        } else {
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
            let convertedDate: NSDate = formatter.dateFromString(date)!
            let convertedMili: Int64 = self.dateToMillis(convertedDate)
            return convertedMili
            
        }
    
    }

    func dateToMillis(date:NSDate) -> Int64{
        let nowDouble = date.timeIntervalSince1970
        return Int64(nowDouble*1000)
    }


      
}

