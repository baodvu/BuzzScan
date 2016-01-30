//
//  ViewController.swift
//  BuzzScan
//
//  Created by Bao Vu on 1/26/16.
//
//

import AVFoundation
import UIKit
import AudioToolbox

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activateButton: UIButton!
    
    var objCaptureSession:AVCaptureSession?
    var objCaptureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    var vwCode:UIView?
    
    var idModel = IDModel()
    var mySettings = Settings()
    var isActivated = true
    
    let playImage = UIImage(named: "Play")
    let pauseImage = UIImage(named: "Pause")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure camera
        self.configureVideoCapture()
        self.addVideoPreviewLayer()
        self.initializeQRView()
        
        let tbc = tabBarController as! IDTabBarController
        idModel = tbc.myID
        if let savedSettings = loadSettings() {
            tbc.mySettings = savedSettings
        }
        mySettings = tbc.mySettings
        
        activateButton.setImage(pauseImage, forState: .Normal)
    }
    
    func configureVideoCapture() {
        let objCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error:NSError?
        let objCaptureDeviceInput: AnyObject!
        do {
            objCaptureDeviceInput = try AVCaptureDeviceInput(device: objCaptureDevice) as AVCaptureDeviceInput
        } catch let error1 as NSError {
            error = error1
            objCaptureDeviceInput = nil
        }
        if (error != nil) {
            let alertController = UIAlertController(title: "Device error", message: "Device not supported", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
                print("Cancel pressed");
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                print("OK pressed");
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        objCaptureSession = AVCaptureSession()
        objCaptureSession?.addInput(objCaptureDeviceInput as! AVCaptureInput)
        let objCaptureMetadataOutput = AVCaptureMetadataOutput()
        objCaptureSession?.addOutput(objCaptureMetadataOutput)
        objCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        objCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeCode39Code]
    }
    
    func addVideoPreviewLayer()
    {
        objCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: objCaptureSession)
        objCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        objCaptureVideoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(objCaptureVideoPreviewLayer!)
        objCaptureSession?.startRunning()
        self.view.bringSubviewToFront(statusLabel)
        self.view.bringSubviewToFront(activateButton)
    }
    
    func initializeQRView() {
        vwCode = UIView()
        vwCode?.layer.borderColor = UIColor.redColor().CGColor
        vwCode?.layer.borderWidth = 2
        self.view.addSubview(vwCode!)
        self.view.bringSubviewToFront(vwCode!)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            vwCode?.frame = CGRectZero
            statusLabel.text = "[detecting]"
            return
        }
        let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeCode39Code {
            let objBarCode = objCaptureVideoPreviewLayer?.transformedMetadataObjectForMetadataObject(objMetadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            vwCode?.frame = objBarCode.bounds;
            if objMetadataMachineReadableCodeObject.stringValue != nil {
                let id = objMetadataMachineReadableCodeObject.stringValue
                let newStatus = "[\(id)]"
                if statusLabel.text != newStatus {
                    if !mySettings.allowDuplicates && id == idModel.idList.last {
                        statusLabel.text = "[duplicate entry]"
                    }
                    else {
                        statusLabel.text = newStatus
                        idModel.idList += [id]
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        AudioServicesPlaySystemSound(1057)
                        NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
                    }
                }
            }
        }
    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showList" {
//            let nextView = segue.destinationViewController as! IDTableViewController
//            nextView.idList = idList
//        }
//    }
    
    @IBAction func toggleScanning(sender: UIButton) {
        if isActivated {
            objCaptureSession?.stopRunning()
            statusLabel.text = "[deactivated]"
            activateButton.setImage(playImage, forState: .Normal)
            isActivated = false
        } else {
            objCaptureSession?.startRunning()
            statusLabel.text = "[detecting]"
            activateButton.setImage(pauseImage, forState: .Normal)
            isActivated = true
        }
    }
    
    
    // MARK: NSCoding
    
    func loadSettings() -> Settings? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Settings.ArchiveURL.path!) as? Settings
    }
    
}