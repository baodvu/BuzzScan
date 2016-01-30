//
//  Settings.swift
//  BuzzScan
//
//  Created by Bao Vu on 1/26/16.
//
//

import Foundation

class Settings: NSObject {
    
    var allowDuplicates = false
    var mailSubject = "[CS2110] Lab attendance"
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("settings")
    
    // MARK: Types
    
    struct PropertyKey {
        static let allowDuplicatesKey = "allowDuplicates"
        static let mailSubjectKey = "mailSubject"
    }
    
    // MARK: Initialization
    
    override init() {
        // Do nothing
    }
    
    init(allowDup: Bool, subject: String) {
        self.allowDuplicates = allowDup
        self.mailSubject = subject
        
        super.init()
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeBool(allowDuplicates, forKey: PropertyKey.allowDuplicatesKey)
        aCoder.encodeObject(mailSubject, forKey: PropertyKey.mailSubjectKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let allowDuplicates = aDecoder.decodeBoolForKey(PropertyKey.allowDuplicatesKey) as Bool
        let mailSubject = aDecoder.decodeObjectForKey(PropertyKey.mailSubjectKey) as! String
        self.init(allowDup: allowDuplicates, subject: mailSubject)
    }

}
