//
//  SyncKitManager.swift
//  Read arXiv
//
//  Created by Frederick Morlock on 8/16/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import Foundation
import SyncKit
import CloudKit

class SyncKitManager {
    private let synchronizer: CloudKitSynchronizer?
    static let shared = SyncKitManager()
    
    private init() {
        if FileManager.default.ubiquityIdentityToken == nil {
            synchronizer = nil
            return
        }
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        synchronizer = CloudKitSynchronizer.privateSynchronizer(containerName: "iCloud.net.nerd.Read-arXiv", managedObjectContext: appDelegate.persistentContainer.viewContext)
        
        if let zoneID = synchronizer?.modelAdapters.first?.recordZoneID {
            synchronizer?.subscribeForChanges(in: zoneID) { (error) in
                if error != nil {
                    print("Error: \(error!)")
                }
            }
        }
    }
    
    func sync(_ callback: @escaping ((Error?) -> ())) {
        synchronizer?.synchronize(completion: callback)
    }
}
