//
//  CalenderHomeViewController.swift
//  TripReminder
//
//  Created by Linda adel on 12/20/21.
//

import UIKit
import FSCalendar
import Firebase
import UserNotifications
import Toast_Swift

// step 2 : conform to delegate protocol in view controller that recive the data
class CalenderHomeViewController: UIViewController, FSCalendarDelegate , AddTripDelegate , updateTripDelegate {
    var trips : [TripModel]!
    var firebaseManger : FirebaseManger!
    var coreDataManger : CoreDataManger!
    var filterdTripArray : [TripModel]!
    var switchControl : UISwitch = UISwitch()
    static var toggleSwitch : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "toggleSwitch")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "toggleSwitch")
        }
    }
    static var switchBool : Bool  {
        get {
            return UserDefaults.standard.bool(forKey: "switchState")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "switchState")
        }
    }
    
    
    //MARK: IBOutlets
    @IBOutlet weak var homeCalender: FSCalendar!{
        didSet{
            homeCalender.delegate = self
            
        }
    }
    
    @IBOutlet weak var dayTripList: UITableView!
    {
        didSet{
            dayTripList.delegate = self
            dayTripList.dataSource = self
        }
    }
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var calenderNavigationItem: UINavigationItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLeftBarButtonSwitch()
        // read switch state from user default
        let defaults = Foundation.UserDefaults.standard
        defaults.setValue(CalenderHomeViewController.switchBool, forKey: "switchState")
        filterdTripArray = [TripModel]()
        trips = [TripModel]()
        firebaseManger = FirebaseManger.shared
        coreDataManger = CoreDataManger()
        getTripsFromLocalStorage()
        applicationFirstTimeLaunch()
        getUserSyncValue()
        
    }
    
    
    func setUpLeftBarButtonSwitch(){
        let leftbarItems : UIView = UIView()
        leftbarItems.frame =  CGRect(x: 0, y: 0, width: 100, height: 30)
       
        switchControl.frame = CGRect(x: 50, y: 0, width: 50, height: 20)
        switchControl.isOn = CalenderHomeViewController.switchBool
        switchControl.isHidden = false
        switchControl.onTintColor = #colorLiteral(red: 0.1045972928, green: 0.9858483672, blue: 0.7946648002, alpha: 1)
        switchControl.sizeToFit()
        switchControl.setOn(CalenderHomeViewController.switchBool, animated: false)
        switchControl.addTarget(self, action: #selector(switchValueDidChange(sender:)), for: .valueChanged)
      
        
        
        let syncLabel : UILabel = UILabel()
        syncLabel.text = "Sync"
        syncLabel.textColor = #colorLiteral(red: 0.1045972928, green: 0.9858483672, blue: 0.7946648002, alpha: 1)
        syncLabel.textAlignment = .center
        syncLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        syncLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        
        leftbarItems.addSubview(syncLabel)
        leftbarItems.addSubview(switchControl)
        // adding left nav item to nav bar
        calenderNavigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftbarItems)
    }
    
    @objc func switchValueDidChange(sender: UISwitch!)
    {
        
        if sender.isOn {
            print("on")
            CalenderHomeViewController.switchBool = true
           
            //syncDataToFireBase
            addingObserverToTripAdded()
            addingObserverToTripRemoved()
            addingObserverToDeletedNote()
            
            if  CalenderHomeViewController.toggleSwitch == true {
                updateTripsInFireBase()
            }
        } else{
            CalenderHomeViewController.switchBool = false
            CalenderHomeViewController.toggleSwitch = false
            print("off")
            
        }
        firebaseManger.addSyncIndicator()
        
        
    }
    //MARK: observer methods
    
    func addingObserverToTripAdded(){
        // observer to listen to added trips
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(syncDataToFireBase(_:)),
                                               name: NSNotification.Name("tripAdded"),
                                               object: nil)
    }
    func addingObserverToDeletedNote(){
        // observer to listen to added trips
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(syncTripNotes(_:)),
                                               name: NSNotification.Name("noteDeleted"),
                                               object: nil)
    }
    func addingObserverToTripRemoved(){
        // observer to listen to added trips
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(syncTripsAfterRemoving(_:)),
                                               name: NSNotification.Name("tripRemoved"),
                                               object: nil)
    }
    
    //MARK: IBActions
    
    
    @objc func syncDataToFireBase(_ notifications : Notification) {

        if let data = notifications.userInfo  {
            if  let  addedTrip = data["trip"] as? TripModel {
                self.firebaseManger.addTripToFirebase(trip: addedTrip)
            }
        }
        
    }
    @objc func syncTripsAfterRemoving(_ notifications : Notification) {
        // delete from firebase
        if let data = notifications.userInfo  {
            if  let  deletedTrip = data["trip"] as? TripModel {
                self.firebaseManger.removeTripFromFirebase(trip: deletedTrip)
            }
        }
        
    }
    @objc func syncTripNotes(_ notifications : Notification) {
        if let data = notifications.userInfo  {
            if  let  noteTrip = data["trip"] as? TripModel , let notes = data["notes"] as? [Notes] {
                firebaseManger.removeNoteFromFirebase(trip: noteTrip , notes: notes)
            }
        }
        
    }
    
    @IBAction func addNewTrip(_ sender: UIBarButtonItem) {
        if let newTripVC = self.storyboard?.instantiateViewController(withIdentifier: "addNewTrip") as? AddNewTripViewController{
            let selectedDate = self.homeCalender.selectedDate
            newTripVC.selectedCalenderDate = selectedDate
            // step 5 : conform delegate of add trip to self
            newTripVC.newTripAdded = self
            newTripVC.modalPresentationStyle = .fullScreen
            self.present(newTripVC, animated: true, completion: nil)}
        
    }
    //MARK: Calender Methods
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let calenderDate = date.description.split(separator: " ")[0]
        self.filterdTripArray = self.trips.filter({($0.tripStartDate?.contains(String(calenderDate)))!})
        self.dayTripList.reloadData()
        
        
        
    }
    //MARK: local notification
    func scheduleLocalNotification(trip : [TripModel]){
        // Step 1: Ask for permission
        //UNUserNotificationCenter.current() : shared instance of notification center that handle request and all operation
        let current = UNUserNotificationCenter.current()
        // Step 2: request autherization from user in order to send notification
        // options : is an array in which we speacify the notification options we need
        current.requestAuthorization(options: [.alert , .badge, .sound]) { (success, error) in
            if success {
                //scheduleLocalNotification
                self.createLocalNotification(trip: self.filterdTripArray)
            }else{
                // error occured
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    //notification has 3 main pieces : 1- content ,  2- trigger , 3- request
    func createLocalNotification(trip : [TripModel]){
        trip.forEach({
            if let title = $0.tripName ,
               let tripDate = $0.tripStartDate?.split(separator: " ")[0] ,
               tripDate >= (self.homeCalender.today?.description.split(separator: " ")[0])!  {
                let upcomingTrips = self.trips.filter({($0.tripStartDate?.contains(String(tripDate)))!})
                // step 3 :  Create the notification content
                let content = UNMutableNotificationContent()
                content.title = "\(title) Trip Reminder"
                content.body = "you have an upcoming trip on \(tripDate)"
                content.badge = NSNumber(value: upcomingTrips.count)
                content.sound = .default
                // step 4 : Create the notification trigger
                // will use trigger date with 5 seconds but there is other trigger options
                let date = Date().addingTimeInterval(5)
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents , repeats: false)
                // Step 5: Create the notification request
                // create a unique id
                let uniqueIdString = UUID().uuidString
                let request = UNNotificationRequest(identifier: uniqueIdString , content: content , trigger: trigger)
                // Step 6: Register the request
                UNUserNotificationCenter.current().add(request) { (error) in
                    // Check the error parameter and handle any errors
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        })
    }
    //MARK: add trip delegete function
    //step 3 : implement delegate function
    func addTripToList(trip: TripModel) {
        trips.append(trip)
        if let currentDate = self.homeCalender.selectedDate?.description.split(separator: " ")[0] {
            self.filterdTripArray = self.trips.filter({($0.tripStartDate?.contains(String(currentDate)))!})}
        // update ui
        
        dayTripList.reloadData()
        self.view.makeToast("Trip added succesfully", duration: 3.0, position: .bottom)
    }
    
    func replaceModifiedTrip(trip: TripModel) {
        trips.removeAll {
            $0.localTripId == trip.localTripId
        }
        trips.append(trip)
        filterdTripArray.removeAll {
            $0.localTripId == trip.localTripId
        }
        filterdTripArray.append(trip)
        dayTripList.reloadData()
    }
    func replaceUpdatedTrip(trip: TripModel) {
        trips.removeAll {
            $0.localTripId == trip.localTripId
        }
        trips.append(trip)
        filterdTripArray.removeAll {
            $0.localTripId == trip.localTripId
        }
        filterdTripArray.append(trip)
        dayTripList.reloadData()
    }
    
    
}
//MARK: table view methods
extension CalenderHomeViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterdTripArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayTripCell", for: indexPath)
        if let dayTripCell = cell as? DayTripsTableViewCell{
            let trip = filterdTripArray[indexPath.row]
            dayTripCell.tripNameLabel.text = trip.tripName
            dayTripCell.startTripButton.addTarget(self, action: #selector(navigationToMaps), for: .touchUpInside)
            dayTripCell.selectionStyle = .none
            if trip.cancelTrip == true {
                dayTripCell.startTripButton.isHidden = true
                dayTripCell.cancelLabel.isHidden = false
            }
            else {
                dayTripCell.startTripButton.isHidden = false
                dayTripCell.cancelLabel.isHidden = true
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trip = filterdTripArray[indexPath.row]
        ViewTripDetails(trip: trip, indexPath: indexPath)
       
        
    }
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let trip = filterdTripArray[indexPath.row]
            self.deleteTrip(trip: trip, indexPath: indexPath)
        }
    }
    //MARK: methods
    func ViewTripDetails(trip : TripModel, indexPath : IndexPath)  {
        
        if let startDate = trip.tripStartDate?.split(separator: " ")[0]
           ,let starttime = trip.tripStartTime
           , let endDate = trip.tripEndDate?.split(separator: " ")[0]
          , let endtime = trip.tripEndTime
        {
            let alert = UIAlertController(title: trip.tripName,
                                          message: " start date : \(startDate) \n To : \( endDate) \n From : \(starttime) \n  To : \(endtime) " ,
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "View Details", style:.default,  handler:
                                          { (UIAlertAction) in
                self.navigateToTripDetails(trip: trip)
            }))
            
           
                
                if trip.cancelTrip == false {
                    alert.addAction(UIAlertAction(title: "Cancel Trip ", style: .cancel, handler: { _ in
                   
                     self.cancelTrip(trip: trip, indexPath: indexPath)
                    self.view.makeToast("Trip Canceled", duration: 3.0, position: .bottom)
                        
                    }))
      
                }else {}
            alert.addAction(UIAlertAction(title: "Delete Trip", style: .destructive, handler: { (UIAlertAction) in
                self.deleteTrip(trip: trip, indexPath: indexPath)
            }))
            
            
            self.present(alert, animated: true, completion: {
                self.dismissAlert(alert)
            })
        }
    }
    func dismissAlert(_ alert : UIAlertController){
        alert.view.superview?.isUserInteractionEnabled = true
        alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
    }
    @objc func dismissOnTapOutside(){
       self.dismiss(animated: true, completion: nil)
    }
    
    func cancelTrip(trip : TripModel , indexPath : IndexPath) {
        filterdTripArray [indexPath.row].cancelTrip = true
        self.dayTripList.reloadData()
        if let tripId = trip.localTripId {
        coreDataManger.cancelTripInLocalStorage(tripId:tripId)
        firebaseManger.cancelTripOnFirebase(trip: trip)
        }
      
    }
    func deleteTrip(trip : TripModel , indexPath : IndexPath) {
        // delete from core data
        if let tripUniqueId = trip.localTripId {
            self.coreDataManger.deleteTrip(tripId: tripUniqueId )}
        // delete from firebase
        // self.firebaseManger.removeTripFromFirebase(trip: trip)
        //update ui
        filterdTripArray.remove(at: indexPath.row)
        trips.removeAll {
            $0.localTripId == trip.localTripId
        }
        self.dayTripList.reloadData()
        //notification for each time a trip is added aka posted
        NotificationCenter.default.post(name: NSNotification.Name("tripRemoved"), object: nil , userInfo: ["trip": trip])
        if CalenderHomeViewController.switchBool == false {
            CalenderHomeViewController.toggleSwitch = true
        }
    }
    func navigateToTripDetails(trip : TripModel){
        if let tripDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "tripDetails") as? TripDetailsViewController{
            tripDetailVC.replacedNotes = self
            tripDetailVC.updatedTrip = self
            tripDetailVC.trip = trip
            tripDetailVC.modalPresentationStyle = .fullScreen
            self.present(tripDetailVC, animated: true, completion: nil)}
    }
    //MARK: get data from core data
    func getTripsFromLocalStorage() {
        trips = coreDataManger.fetchTrips()
        // call notification after getting data
        self.scheduleLocalNotification(trip: self.trips)
        if let currentDate = self.homeCalender.today?.description.split(separator: " ")[0] {
            self.filterdTripArray = self.trips.filter({($0.tripStartDate?.contains(String(currentDate)))!})
           
        }
    }
    
    //MARK: get data from firebase
    func getUserTrips(){
        
        firebaseManger.getUserTripsFromFirebase { (tripsData) in
            self.trips = tripsData
            // call notification after getting data
            self.scheduleLocalNotification(trip: self.trips)
            if let currentDate = self.homeCalender.today?.description.split(separator: " ")[0] {
                self.filterdTripArray = self.trips.filter({($0.tripStartDate?.contains(String(currentDate)))!})
                print("calender data is \(String(describing: self.homeCalender.today?.description))")
                print("filtered array \(String(describing: self.filterdTripArray))")
                self.dayTripList.reloadData()
            }
            // adding trips from firebase to core data
            for trip in self.trips{
                self.coreDataManger.addTrips(trip: trip)
            }
            
        }
        
        
    }
    //MARK: update trips added and removed when switch was off
    func updateTripsInFireBase(){
        
        firebaseManger.removeAllTrips()
        let trips : [TripModel] = coreDataManger.fetchTrips()
        for trip in trips{
            firebaseManger.addTripToFirebase(trip: trip)
        }
        
    }
    
    //MARK: check for first time launch
    func applicationFirstTimeLaunch(){
        if UserDefaults.standard.bool(forKey: "First Launch") == true {
            print("second++")
            if  CalenderHomeViewController.switchBool == true {
                // delete all local trips
                coreDataManger.deleteAllTrip()
                // get trips from firebase and saved in local trips
                getUserTrips()
                //syncDataToFireBase
                addingObserverToTripAdded()
                addingObserverToTripRemoved()
                addingObserverToDeletedNote()
            }
            UserDefaults.standard.setValue(true, forKey: "First Launch")
        }else{
            print("first")
            // first time run
            // if user open sync
            if CalenderHomeViewController.switchBool {
                // delete all local trips
                coreDataManger.deleteAllTrip()
                // get trips from firebase and saved in local trips
                getUserTrips()
                //syncDataToFireBase
                addingObserverToTripAdded()
                addingObserverToTripRemoved()
                addingObserverToDeletedNote()
                
            }
            
            UserDefaults.standard.setValue(true, forKey: "First Launch")
        }
    }
    //MARK: map navigation
    @objc func navigationToMaps(sender : UIButton){
        print("navigate for cell")
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let tripStartPoint = filterdTripArray[indexPath.row].tripStart , let tripEndPoint = filterdTripArray[indexPath.row].tripEnd {
            let startAddress = tripStartPoint.replacingOccurrences(of: " ", with: "+")
            let destinationAddress = tripEndPoint.replacingOccurrences(of: " ", with: "+")
            print("start at \(startAddress) ends at \(destinationAddress)")
            // apple map Url schema
            if let targetURL = URL(string: "http://maps.apple.com/?saddr=\(startAddress)&daddr=\(destinationAddress)")
            
            {
                print("target url : \(targetURL)")
                UIApplication.shared.open(targetURL, options: [:] , completionHandler: nil)
                
                
            }
        }
    }
    func getUserSyncValue(){
        firebaseManger.getSyncIndicator(completion: { [weak self] syncValue in
            print("syncValue \(String(describing: syncValue))")
            if let sync = syncValue {
                CalenderHomeViewController.switchBool = sync
                DispatchQueue.main.async {             
                    self?.switchControl.setOn(sync, animated: false)
                    
                }
                
                print(" syncToFireBase \( String(describing:  CalenderHomeViewController.switchBool ))")
                
            }
        })
        
    }
    
}
