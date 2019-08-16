//
//  Bookmarks+CoreDataClass.swift
//  Read arXiv
//
//  Created by Frederick Morlock on 8/16/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//
//

import Foundation
import CoreData
import SyncKit

@objc(Bookmarks)
public class Bookmarks: NSManagedObject, PrimaryKey {
    public static func primaryKey() -> String {
        return "articleID"
    }
}
