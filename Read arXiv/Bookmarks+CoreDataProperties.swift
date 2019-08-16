//
//  Bookmarks+CoreDataProperties.swift
//  Read arXiv
//
//  Created by Frederick Morlock on 8/16/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//
//

import Foundation
import CoreData


extension Bookmarks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bookmarks> {
        return NSFetchRequest<Bookmarks>(entityName: "Bookmarks")
    }

    @NSManaged public var articleAuthors: String
    @NSManaged public var articleDescription: String
    @NSManaged public var articleID: String
    @NSManaged public var articleTitle: String

}
