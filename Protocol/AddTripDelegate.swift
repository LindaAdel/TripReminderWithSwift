//
//  AddTripDelegate.swift
//  TripReminder
//
//  Created by Linda adel on 12/30/21.
//

import Foundation
// step 1 : make delegate protocol
protocol AddTripDelegate {
    
    func addTripToList(trip : TripModel)
    func replaceModifiedTrip(trip : TripModel)
}
protocol updateTripDelegate {
    func replaceUpdatedTrip(trip : TripModel)
}
