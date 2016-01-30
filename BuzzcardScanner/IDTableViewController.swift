//
//  IDTableViewController.swift
//  BuzzScan
//
//  Created by Bao Vu on 1/26/16.
//
//

import UIKit
import MessageUI

class IDTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    var idModel = IDModel()
    var mySettings = Settings()

    override func viewDidLoad() {
        super.viewDidLoad()
        let tcb = self.tabBarController as! IDTabBarController
        idModel = tcb.myID
        mySettings = tcb.mySettings
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:",name:"load", object: nil)
    }
    
    func loadList(notification: NSNotification){
        //load data here
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idModel.idList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "IDTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! IDTableViewCell

        cell.id.text = idModel.idList[indexPath.row]

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func clearAll(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Confirm your action", message: "Do you really want to delete everything?", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
            // Do nothing
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
            self.idModel.idList = []
            self.tableView.reloadData()
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func upload(sender: UIBarButtonItem) {
        var fileExtension: String
        var fileMimeType: String
        switch mySettings.fileType {
        case .Text: fileExtension = ".txt"
            fileMimeType = "text/txt"
        case .CSV:  fileExtension = ".csv"
            fileMimeType = "text/csv"
        }
        
        // Get date
        let currentDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.stringFromDate(currentDate)
        
        // Create text file containing the data
        let file = "log-" + dateString + fileExtension
        let fileContent = idModel.idList.joinWithSeparator("\n")
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(file)
            
            // Write to file
            do {
                try fileContent.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
                
                // Compose an email
                if (MFMailComposeViewController.canSendMail()) {
                    let mailComposer = MFMailComposeViewController()
                    mailComposer.mailComposeDelegate = self
                    
                    // Set the subject and message
                    mailComposer.setSubject(mySettings.mailSubject)
                    mailComposer.setMessageBody("(see attached file)", isHTML: false)
                    
                    if let fileData = NSData(contentsOfFile: path) {
                        mailComposer.addAttachmentData(fileData, mimeType: fileMimeType, fileName: file)
                    }
                    
                    self.presentViewController(mailComposer, animated: true, completion: nil)
                }
                
                // Remove file
                let filemgr = NSFileManager.defaultManager()
                
                do {
                    try filemgr.removeItemAtPath(path)
                } catch {
                    print("Remove failed")
                }
            }
            catch {
                // error handling
            }
        }
        
//        let textToShare = idModel.idList.joinWithSeparator("\n")
//        
//        let objectsToShare = [textToShare]
//        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//        activityVC.setValue("[CS2110] Lab Attendance", forKey: "subject")
//        
//        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}
