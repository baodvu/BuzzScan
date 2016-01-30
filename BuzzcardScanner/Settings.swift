//
//  Settings.swift
//  BuzzScan
//
//  Created by Bao Vu on 1/26/16.
//
//

import Foundation

enum ExportFileType: Int {
    case Text, CSV
}

class Settings: NSObject {
    
    var allowDuplicates = false
    var mailSubject = "[CS2110] Lab attendance"
    var fileType = ExportFileType.CSV
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("settings")
    
    // MARK: Types
    
    struct PropertyKey {
        static let allowDuplicatesKey = "allowDuplicates"
        static let mailSubjectKey = "mailSubject"
        static let fileTypeKey = "fileType"
    }
    
    // MARK: Initialization
    
    override init() {
        // Do nothing
    }
    
    init(allowDup: Bool, subject: String, fileType: ExportFileType) {
        self.allowDuplicates = allowDup
        self.mailSubject = subject
        self.fileType = fileType
        
        super.init()
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeBool(allowDuplicates, forKey: PropertyKey.allowDuplicatesKey)
        aCoder.encodeObject(mailSubject, forKey: PropertyKey.mailSubjectKey)
        aCoder.encodeInteger(fileType.rawValue, forKey: PropertyKey.fileTypeKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let allowDuplicates = aDecoder.decodeBoolForKey(PropertyKey.allowDuplicatesKey) as Bool
        let mailSubject = aDecoder.decodeObjectForKey(PropertyKey.mailSubjectKey) as! String
        let fileTypeValue = aDecoder.decodeIntegerForKey(PropertyKey.fileTypeKey) as Int
        self.init(allowDup: allowDuplicates, subject: mailSubject, fileType: ExportFileType(rawValue: fileTypeValue)!)
    }

}
