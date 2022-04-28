//
//  TripDataModel+CoreDataProperties.swift
//  TripReminder
//
//  Created by Linda adel on 1/11/22.
//
//

import Foundation
import CoreData


extension TripDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TripDataModel> {
        return NSFetchRequest<TripDataModel>(entityName: "TripDataModel")
    }

    @NSManaged public var localTripId: String?
    @NSManaged public var tripEnd: String?
    @NSManaged public var tripEndDate: String?
    @NSManaged public var tripEndTime: String?
    @NSManaged public var tripName: String?
    @NSManaged public var tripStart: String?
    @NSManaged public var tripStartDate: String?
    @NSManaged public var tripStartTime: String?
    @NSManaged public var tripType: String?
    @NSManaged public var cancelTrip : Bool
    @NSManaged public var notes: NSSet?

}

// MARK: Generated accessors for notes
extension TripDataModel {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: TripNotesDataModel)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: TripNotesDataModel)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}

extension TripDataModel : Identifiable {

}
