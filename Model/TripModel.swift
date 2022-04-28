//
//  TripModel.swift
//  TripReminder
//
//  Created by Linda adel on 12/21/21.
//

import Foundation


struct TripModel : Codable {
    
    var tripId : String?
    var localTripId : String?
    var tripName : String?
    var tripStart : String?
    var tripEnd : String?
    var tripStartDate : String?
    var tripEndDate : String?
    var tripStartTime : String?
    var tripEndTime : String?
    var triptype : String?
    var cancelTrip : Bool?
    var notes : [Notes]?
   
    init(){
        localTripId = UUID().uuidString
        triptype = "oneDirection"
        cancelTrip = false
        notes = [Notes]()
    }

    
}
public class Notes : NSObject , Codable , NSCoding {
   
    var noteId : String?
    var title : String?
    var body : String?
    var isOpened : Bool?
    var editNote : Bool?
    
    override init() {
        super.init()
        noteId = UUID().uuidString
        isOpened = false
        editNote = false
    }
    
    //encode() is used when saving
     public func encode(with coder: NSCoder) {
         coder.encode(title, forKey: "title")
         coder.encode(body, forKey: "body")
         coder.encode(isOpened, forKey: "isOpened")
     }
     
     //The initializer is used when loading objects of this class
     public required init?(coder: NSCoder) {
         title = coder.decodeObject(forKey: "title") as? String
         body = coder.decodeObject(forKey: "body") as? String
         isOpened = coder.decodeBool(forKey: "isOpened")
     }
     
     


}


// enum cant be represented to obj c only eum of type int
//public enum TripType : String  {
//
//   case oneDirection
//   case Round
//
//
//}
//extension TripType : Codable {
//
//    enum Key: CodingKey {
//            case rawValue
//        }
//
//    enum CodingError: Error {
//            case unknownValue
//        }
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: Key.self)
//        let rawValue = try container.decode(Int.self, forKey: .rawValue)
//        switch rawValue {
//        case 0:
//            self = .oneDirection
//        case 1:
//            self = .Round
//        default:
//            throw CodingError.unknownValue
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: Key.self)
//                switch self {
//                case .oneDirection :
//                    try container.encode(0, forKey: .rawValue)
//                case .Round :
//                    try container.encode(1, forKey: .rawValue)
//                }
//
//    }
//}
    
    

