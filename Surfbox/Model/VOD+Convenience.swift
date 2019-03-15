//
//  VOD+Convenience.swift
//  Surfbox
//
//  Created by Moses Robinson on 3/14/19.
//  Copyright © 2019 Moses Robinson. All rights reserved.
//

import Foundation
import CoreData

extension VOD {
    
    convenience init(title: String, id: Int64, posterSmall: String, releaseYear: Int64, rating: String, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        (self.title, self.id, self.posterSmall, self.releaseYear, self.rating) = (title, id, posterSmall, releaseYear, rating)
    }
    
    convenience init?(vodRepresentation: VODRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        let id = Int64(vodRepresentation.id)
        let releaseYear = Int64(vodRepresentation.releaseYear)
        
        self.init(title: vodRepresentation.title, id: id, posterSmall: vodRepresentation.posterSmall, releaseYear: releaseYear, rating: vodRepresentation.rating, context: context)
    }
    
}
