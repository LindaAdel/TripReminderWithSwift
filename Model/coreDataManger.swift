//
//  coreDataManger.swift
//  TripReminder
//
//  Created by Linda adel on 12/29/21.
//

import Foundation
import UIKit
import CoreData

struct CoreDataManger {
    
    func addTrips( trip : TripModel ){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.persistentContainer.viewContext
        let tripObj = TripDataModel(context: manageContext)
        tripObj.setValue(trip.localTripId, forKey: "localTripId")
        tripObj.setValue(trip.tripName, forKey: "tripName")
        tripObj.setValue(trip.tripStart, forKey: "tripStart")
        tripObj.setValue(trip.tripEnd, forKey: "tripEnd")
        tripObj.setValue(trip.tripStartDate, forKey: "tripStartDate")
        tripObj.setValue(trip.tripEndDate, forKey: "tripEndDate")
        tripObj.setValue(trip.tripStartTime, forKey: "tripStartTime")
        tripObj.setValue(trip.tripEndTime, forKey: "tripEndTime")
        tripObj.setValue(trip.triptype, forKey: "tripType")
        tripObj.setValue(trip.cancelTrip, forKey: "cancelTrip")
        for note in trip.notes! {
            let noteObj = TripNotesDataModel(context: manageContext)
            noteObj.setValue(note.noteId, forKey: "noteId")
            noteObj.setValue(note.title, forKey: "noteTitle")
            noteObj.setValue(note.body, forKey: "noteBody")
            noteObj.setValue(note.isOpened, forKey: "isOpened")
            tripObj.addToNotes(noteObj)
        }
        
        do{
            try  manageContext.save()
        }catch let error{
            print(error)
        }
    }
    
    func deleteTrip(tripId : String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TripDataModel>(entityName: "TripDataModel")
        fetchRequest.predicate = NSPredicate(format: "localTripId == %@", tripId)
        do{
            let foundedItem = try manageContext.fetch(fetchRequest)
            if foundedItem.count != 0 {
                for i in foundedItem{
                    manageContext.delete(i)
                }
            }
            try manageContext.save()
        }catch let error{
            print(error)
        }
    }
    func cancelTripInLocalStorage(tripId : String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TripDataModel>(entityName: "TripDataModel")
        fetchRequest.predicate = NSPredicate(format: "localTripId == %@", tripId)
        do{
            let foundedItem = try manageContext.fetch(fetchRequest)
            if foundedItem.count != 0 {
                for i in foundedItem{
                    i.cancelTrip = true
                }
            }
            try manageContext.save()
        }catch let error{
            print(error)
        }
    }
    func updateTrip(with tripId : String ,and tripInfo : TripModel){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TripDataModel>(entityName: "TripDataModel")
        fetchRequest.predicate = NSPredicate(format: "localTripId == %@", tripId)
        do{
            let foundedItem = try manageContext.fetch(fetchRequest)
            if foundedItem.count != 0 {
                for i in foundedItem{
                    i.tripName = tripInfo.tripName
                    i.tripStart = tripInfo.tripStart
                    i.tripEnd = tripInfo.tripEnd
                    i.tripType = tripInfo.triptype
                    i.tripStartTime = tripInfo.tripStartTime
                    i.tripEndTime = tripInfo.tripEndTime
                    i.tripStartDate = tripInfo.tripStartDate
                    i.tripEndDate = tripInfo.tripEndDate
                    i.removeFromNotes(i.notes!)
                    for note in tripInfo.notes! {
                        let noteObj = TripNotesDataModel(context: manageContext)
                        noteObj.setValue(note.noteId, forKey: "noteId")
                        noteObj.setValue(note.title, forKey: "noteTitle")
                        noteObj.setValue(note.body, forKey: "noteBody")
                        noteObj.setValue(note.isOpened, forKey: "isOpened")
                        i.addToNotes(noteObj)
                    }
                }
            }
            try manageContext.save()
        }catch let error{
            print(error)
        }
        
    }
    
    func deleteAllTrip(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TripDataModel>(entityName: "TripDataModel")
        
        do{
            let foundedItem = try manageContext.fetch(fetchRequest)
            if foundedItem.count != 0 {
                for i in foundedItem{
                    manageContext.delete(i)
                }
            }
            try manageContext.save()
        }catch let error{
            print(error)
        }
    }
    
    func fetchTrips() -> [TripModel] {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TripDataModel>(entityName: "TripDataModel")
        var localTripArray = [TripModel]()
        do{
            let coreTripsArray  = try manageContext.fetch(fetchRequest)
            
            for trip in coreTripsArray {
                var temTrip = TripModel()
                var notesSet = Set<TripNotesDataModel>()
                var notesArray = [Notes]()
                
                temTrip.localTripId = trip.value(forKey: "localTripId") as? String
                temTrip.tripName =  trip.value(forKey: "tripName" ) as? String
                temTrip.tripStart = trip.value(forKey: "tripStart") as? String
                temTrip.tripEnd = trip.value(forKey: "tripEnd") as? String
                temTrip.tripStartDate = trip.value(forKey: "tripStartDate") as? String
                temTrip.tripEndDate = trip.value(forKey: "tripEndDate") as? String
                temTrip.tripStartTime = trip.value(forKey: "tripStartTime") as? String
                temTrip.tripEndTime = trip.value(forKey: "tripEndTime") as? String
                temTrip.triptype = trip.value(forKey: "tripType") as? String
                temTrip.cancelTrip = trip.value(forKey: "cancelTrip") as? Bool
                if let notes = trip.value(forKey: "notes") as? Set<TripNotesDataModel> {
                    notesSet = notes
                    
                    for noteItem in notesSet {
                        let note = Notes()
                        note.noteId = noteItem.value(forKey: "noteId") as? String
                        note.title = noteItem.value(forKey: "noteTitle") as? String
                        note.body = noteItem.value(forKey: "noteBody") as? String
                        note.isOpened = noteItem.value(forKey: "isOpened") as? Bool
                        notesArray.append(note)
                    }
                    
                }
                temTrip.notes = notesArray
                print("notes array \(notesArray)" )
                localTripArray.append(temTrip)
            }
            
        }catch let error{
            print(error)
            
        }
        return localTripArray
    }
    func deleteNote(noteId : String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TripNotesDataModel")
        fetchRequest.predicate = NSPredicate(format: "noteId == %@", noteId)
        do{
            let foundedItem = try manageContext.fetch(fetchRequest)
            if foundedItem.count != 0 {
                for i in foundedItem{
                    manageContext.delete(i)
                }
            }
            try manageContext.save()
        }catch let error{
            print(error)
        }
        
    }
    
}


