//
//  TripNotesDataModel+CoreDataProperties.swift
//  TripReminder
//
//  Created by Linda adel on 1/11/22.
//
//

import Foundation
import CoreData


extension TripNotesDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TripNotesDataModel> {
        return NSFetchRequest<TripNotesDataModel>(entityName: "TripNotesDataModel")
    }

    @NSManaged public var isOpened: Bool
    @NSManaged public var noteBody: String?
    @NSManaged public var noteId: String?
    @NSManaged public var noteTitle: String?
    @NSManaged public var editNote : Bool
    @NSManaged public var trip: TripDataModel?

}

extension TripNotesDataModel : Identifiable {

}
