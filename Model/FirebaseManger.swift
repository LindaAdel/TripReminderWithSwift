//
//  FirebaseManger.swift
//  TripReminder
//
//  Created by Linda adel on 12/22/21.
//

import Foundation
import Firebase
import CodableFirebase

class FirebaseManger {
    
    var databaseRefrence : DatabaseReference!
    var currentUser : User?
    var userId : String?
    var userMail : String!
    var tripsArray : [TripModel] = []
    var syncBool : Bool?
    var userPassword : String?
    var notesArray : [Notes] = []
    
    static let shared = FirebaseManger()
    
    func updateUserData() {
        currentUser = Auth.auth().currentUser
        userId = currentUser?.uid
        userMail = currentUser?.email
        
    }
    private init() {
        databaseRefrence = Database.database().reference().ref
        updateUserData()
        // check if user signed out
        Auth.auth().addStateDidChangeListener {  auth, user in
            if let user = user {
                // user is signed in
                self.currentUser = user
                self.userId = self.currentUser?.uid
                self.userMail = self.currentUser?.email
                
            }else {
                //  user signed out
            }
        }
    }
   
    //MARK: Add sync bool to each user
    func addSyncIndicator(){
        if let userIdentifier = userId {
            databaseRefrence.child("users").child(userIdentifier).child("sync").setValue(CalenderHomeViewController.switchBool)
        }
    }
    
    //MARK: trips
    func addTripToFirebase(trip : TripModel){
        if let tripNotes = trip.notes {
            var notes = [[String : Any]]()
            for note in tripNotes {
                if let body = note.body , let title = note.title {
                    let tripNote = [
                        "noteTitle" : title ,
                        "noteBody"  : body ,
                        "noteState" : note.isOpened!
                    ] as [String : Any]
                    notes.append(tripNote)
                }
            }
            if let tripName = trip.tripName , let tripStart = trip.tripStart , let  tripEnd = trip.tripEnd , let tripStartDate = trip.tripStartDate , let tripEndDate = trip.tripEndDate , let tripStartTime = trip.tripStartTime , let  tripEndTime = trip.tripEndTime , let triptype = trip.triptype , let tripId = trip.localTripId , let cancelTrip = trip.cancelTrip {
                let tripInfo = [
                    "tripName" : tripName,
                    "tripStartPoint" : tripStart ,
                    "tripEndPoint" : tripEnd ,
                    "tripStartDate" : tripStartDate ,
                    "tripEndDate" : tripEndDate ,
                    "tripStartTime" : tripStartTime ,
                    "tripEndTime" : tripEndTime ,
                    "tripType" : triptype,
                    "cancelTrip" : cancelTrip ,
                    "tripNotes" : notes
                ] as [String : Any]
                if let userIdentifier = userId {
                    databaseRefrence.child("users").child(userIdentifier).child("userTrips").child(tripId).setValue(tripInfo)
                }
            }
        }
        
        
    }
    
    
    func removeTripFromFirebase(trip : TripModel){
        // in case of firebase autoId
        //        if let tripKey = trip.tripId {
        //            databaseRefrence.child("users").child(userId).child("userTrips").child(tripKey).removeValue()
        //        }
        if let tripKey = trip.localTripId ,let userIdentifier = userId{
            databaseRefrence.child("users").child(userIdentifier).child("userTrips").child(tripKey).removeValue()
        }
    }
    func removeAllTrips(){
        if let userIdentifier = userId {
            databaseRefrence.child("users").child(userIdentifier).child("userTrips").removeValue()
        }
    }
    func cancelTripOnFirebase(trip : TripModel){
        if let tripKey = trip.localTripId ,let userIdentifier = userId{
            databaseRefrence.child("users").child(userIdentifier).child("userTrips").child(tripKey).updateChildValues(["cancelTrip" : true])
            
        }
    }
    
    func removeNoteFromFirebase(trip : TripModel , notes :[Notes]){
        let tripNotes = notes
        var newNotes = [[String : Any]]()
        for note in tripNotes {
            if let body = note.body , let title = note.title {
                let tripNote = [
                    "noteTitle" : title ,
                    "noteBody"  : body ,
                    "noteState" : note.isOpened!
                ] as [String : Any]
                newNotes.append(tripNote)
            }
        }
        // if let tripKey = trip.tripId {
        if let tripKey = trip.localTripId  ,let userIdentifier = userId {
            databaseRefrence.child("users").child(userIdentifier).child("userTrips").child(tripKey).child("tripNotes").removeValue()
            databaseRefrence.child("users").child(userIdentifier).child("userTrips").child(tripKey).child("tripNotes").setValue(newNotes)
        }
    }
    //MARK: get sync bool to each user
    func getSyncIndicator(completion :@escaping (Bool?)->()){
        if let userIdentifier = userId {
            databaseRefrence.child("users").child(userIdentifier).child("sync").observeSingleEvent(of: .value , with: { (dataSnapshot) in
                // Get user value
                if dataSnapshot.exists()
                {
                    if let data = dataSnapshot.value as? Bool{
                        self.syncBool =  data
                        
                    }
                    
                    completion(self.syncBool)
                }else
                {
                    print("snapshot doesnt exist")
                    completion(false)
                }
            }){ error in
                print(error.localizedDescription)
            }
        }
    }
    
    func getUserTripsFromFirebase(completion :@escaping ([TripModel]?)->()){
        if let userIdentifier = userId {
            databaseRefrence.child("users").child(userIdentifier).child("userTrips").observeSingleEvent(of: .value , with: { (dataSnapshot) in
                // Get user value
                if dataSnapshot.exists()
                {
                    
                    if let data = dataSnapshot.value as? [String : NSDictionary]
                    {
                        var trip = TripModel()
                        
                        
                        print("data is \(String(describing: data))")
                        
                        data.forEach({ item in
                            // in case of firebase auto id
                            // trip.tripId = item.key
                            trip.localTripId = item.key
                            print("key is \(String(describing: trip.tripId))")
                            let tripItems = item.value
                            print("trip item  is \(tripItems)")
                            
                            
                            trip.tripName = tripItems["tripName"] as? String
                            trip.tripStart = tripItems["tripStartPoint"] as? String
                            trip.tripEnd = tripItems["tripEndPoint"] as? String
                            trip.tripStartDate = tripItems["tripStartDate"] as? String
                            trip.tripEndDate = tripItems["tripEndDate"] as? String
                            trip.tripStartTime = tripItems["tripStartTime"] as? String
                            trip.tripEndTime = tripItems["tripEndTime"] as? String
                            //                    trip.triptype = (tripItems["tripType"] as? TripType.RawValue).map { TripType(rawValue: $0) } as? TripType
                            trip.triptype = tripItems["tripType"] as? String
                            trip.cancelTrip = tripItems["cancelTrip"] as? Bool
                            if let notes = tripItems["tripNotes"] as? [[String : Any]] {
                                
                                
                                self.notesArray.removeAll()
                                notes.forEach {item in
                                    
                                    print("note item is \(item)")
                                    let note = Notes()
                                    note.title = item["noteTitle"] as? String
                                    note.body = item["noteBody"] as? String
                                    note.isOpened = item["noteState"] as? Bool
                                    
                                    self.notesArray.append(note)
                                    
                                    
                                }
                                
                                trip.notes = self.notesArray
                            }
                            
                            // trip.notes = notes
                            
                            print("trip is \(trip)")
                            self.tripsArray.append(trip)
                            print("array count is \(self.tripsArray.count)")
                            
                        })
                    }
                    completion(self.tripsArray)
                }
                else
                {
                    print("snapshot doesnt exist")
    
                }
                
                
            }){ error in
                print(error.localizedDescription)
            }
            
            
        }
    }
}


