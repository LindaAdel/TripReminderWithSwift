//
//  AddNewTripViewController.swift
//  TripReminder
//
//  Created by Linda adel on 12/21/21.
//

import UIKit
import Firebase
import GooglePlaces
import GoogleMapsBase



class AddNewTripViewController: UIViewController {
    
    var trip : TripModel!
    var selectedCalenderDate : Date!
    var coreDataTrip : CoreDataManger!
    var tableNotes : [Notes]!
    var firebaseManger : FirebaseManger!
    var tripType : String!
    // step 4 : object from delegate procotol
    var distinguishTextFields : Bool?
    var newTripAdded : AddTripDelegate!
    var oneDirectionType : Bool = true {
        didSet{
            
        }
    }
    var roundType : Bool = false {
        didSet{
            
        }
    }
    
    //MARK: IBOutlets
    
    @IBOutlet weak var tripNameTextField: UITextField!
    
    @IBOutlet weak var tripStartDestinationTextField: UITextField!
    
    @IBOutlet weak var tripEndDestinationTextField: UITextField!
    
    @IBOutlet weak var tripStartDateInput: UIDatePicker!
    
    @IBOutlet weak var tripEndDateInput: UIDatePicker!
    
    @IBOutlet weak var tripStartTimeInput: UIDatePicker!
    
    @IBOutlet weak var tripEndTimeInput: UIDatePicker!
    
    @IBOutlet weak var notesList: UITableView!{
        didSet{
            notesList.delegate = self
            notesList.dataSource = self
        }
    }
    
    
    @IBOutlet weak var oneDirectionChecked: UIButton!
    
    @IBOutlet weak var roundChecked: UIButton!
    
    
    @IBOutlet weak var TimeErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TimeErrorLabel.isHidden = true
        trip = TripModel()
        coreDataTrip = CoreDataManger()
        if selectedCalenderDate != nil {
            self.tripStartDateInput.date = selectedCalenderDate
            tripEndDateInput.minimumDate = selectedCalenderDate
            
            
        }
        setPicker()
        tableNotes = []
        firebaseManger = FirebaseManger.shared
        // Do any additional setup after loading the view.
    }
    //MARK: IBAction of textfield autocomplete at EditingDidBegin
    @IBAction func getStartDestination(_ sender: UITextField) {
        distinguishTextFields = false
        tripStartDestinationTextField.resignFirstResponder()
        let autocomplete = GMSAutocompleteViewController()
        autocomplete.delegate = self
        // Specify the place data types to return.
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue:UInt(GMSPlaceField.name.rawValue) |
                                                    UInt(GMSPlaceField.placeID.rawValue) |
                                                    UInt(GMSPlaceField.coordinate.rawValue) |
                                                    GMSPlaceField.addressComponents.rawValue |
                                                    GMSPlaceField.formattedAddress.rawValue )
        
        
        autocomplete.placeFields = fields
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocomplete.autocompleteFilter = filter
       
        present(autocomplete, animated: true, completion: nil)
    }
    @IBAction func getEndDestination(_ sender: UITextField) {
        distinguishTextFields = true
        tripEndDestinationTextField.resignFirstResponder()
        let autocompleteEndDestination = GMSAutocompleteViewController()
        autocompleteEndDestination.delegate = self
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue:UInt(GMSPlaceField.name.rawValue) |
                                                    UInt(GMSPlaceField.placeID.rawValue) |
                                                    UInt(GMSPlaceField.coordinate.rawValue) |
                                                    GMSPlaceField.addressComponents.rawValue |
                                                    GMSPlaceField.formattedAddress.rawValue)
        
        autocompleteEndDestination.placeFields = fields
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteEndDestination.autocompleteFilter = filter
        present(autocompleteEndDestination, animated: true, completion: nil)
        
    }
    
    //MARK: IBActions
    @IBAction func oneDirectionTripType(_ sender: UIButton){
        switch sender.state {
        case .highlighted:
            oneDirectionType = true
            roundType = false
        default:
            oneDirectionType = false
            roundType = false
        }
        
        // toggle checkbox
        if sender.isSelected {
            sender.isSelected = false
            roundChecked.isSelected = false
            
        }else{
            sender.isSelected = true
            roundChecked.isSelected = false
            
            
        }
    }
    
    
    @IBAction func roundTripType(_ sender: UIButton) {
        switch sender.state {
        case .highlighted:
            roundType = true
            oneDirectionType = false
            
        default:
            roundType = false
            oneDirectionType = false
        }
        // toggle checkbox
        if sender.isSelected {
            sender.isSelected = false
            oneDirectionChecked.isSelected = false
            
        }else{
            sender.isSelected = true
            oneDirectionChecked.isSelected = true
            
        }
    }
    
    
    @IBAction func backToCalender(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNewNote(_ sender: UIButton) {
        newNoteAlert()
    }
    
    @IBAction func addNewTrip(_ sender: UIButton) {
        addTripInfo()
        
    }
}
extension AddNewTripViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath)
        let note = tableNotes[indexPath.row]
        cell.textLabel?.text = note.title
        if let noteStatus =  note.isOpened {
            cell.accessoryType = noteStatus ? .checkmark : .none}
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = tableNotes[indexPath.row]
        viewNotes(note: note)
        note.isOpened = true
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            // update firebase
            // update ui
            tableNotes.remove(at: indexPath.row )
            firebaseManger.removeNoteFromFirebase( trip: trip, notes: tableNotes)
            notesList.reloadData()
            
        }
    }
    
    
    // MARK: methodes
    
    func viewNotes(note : Notes){
        let alert = UIAlertController(title: note.title, message: note.body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Edit", style: .default , handler: { _ in
            self.editNote(note: note)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func editNote(note : Notes){
        let alert = UIAlertController(title: "Edit Note", message: "", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (noteTitletextField) in
            noteTitletextField.text = note.title
            noteTitletextField.placeholder = "note Title"
        }
        alert.addTextField { (noteBodyTextField) in
            noteBodyTextField.text = note.body
            noteBodyTextField.placeholder = "note Body"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [ weak alert] (_) in
            let noteTitletextField = alert?.textFields![0]
            let newNoteTitle = noteTitletextField?.text
            let noteBodyTextField = alert?.textFields![1]
            let newNoteBody = noteBodyTextField?.text
            let newNote = Notes()
            newNote.title = newNoteTitle
            newNote.body = newNoteBody
            newNote.isOpened = false
            newNote.noteId = note.noteId
            if let tilteStatus = newNoteTitle?.isEmpty , let bodyStatus = newNoteBody?.isEmpty{
                if !tilteStatus && !bodyStatus {
                    self.replaceEditNote(note: newNote)
                    self.notesList.reloadData()
                }}
          
            
            
        }))
    
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)

    }
    func replaceEditNote(note : Notes) {
        tableNotes.removeAll {
            $0.noteId == note.noteId
        }
        tableNotes.append(note)
    
    }
    
    func newNoteAlert() {
        let alert = UIAlertController(title: "New Note", message: "", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (noteTitletextField) in
            noteTitletextField.text = ""
            noteTitletextField.placeholder = "note Title"
        }
        alert.addTextField { (noteBodyTextField) in
            noteBodyTextField.text = ""
            noteBodyTextField.placeholder = "note Body"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [ weak alert] (_) in
            let noteTitletextField = alert?.textFields![0]
            let newNoteTitle = noteTitletextField?.text
            let noteBodyTextField = alert?.textFields![1]
            let newNoteBody = noteBodyTextField?.text
            let newNote = Notes()
            newNote.title = newNoteTitle
            newNote.body = newNoteBody
            newNote.isOpened = false
            if let tilteStatus = newNoteTitle?.isEmpty , let bodyStatus = newNoteBody?.isEmpty{
            if !tilteStatus && !bodyStatus {
                self.tableNotes.append(newNote)
                self.notesList.reloadData()
            }
           
            }
            
        }))
    
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    //    func tripTypeResult() -> TripType {
    //        switch tripType {
    //        case .oneDirection: if oneDirectionType { return "oneDirection"}
    //        case .Round : if roundType{ return "Round"}
    //        default : break
    //        }
    //
    //    }
    
    func tripTypeResult() -> String {
        if oneDirectionType {
            return "oneDirection"
        }
        if roundType {
            return "Round"
        }
        return "oneDirection"
    }
    func addTripInfo(){
        if checkEmptyfields() && checkTimeAccordingToDate() {
            let trip = setTripValue()
            coreDataTrip.addTrips(trip: trip)
            newTripAdded.addTripToList(trip: trip)
            dismiss(animated: true, completion: nil)
            //notification for each time a trip is added aka posted
            NotificationCenter.default.post(name: NSNotification.Name("tripAdded"), object: nil , userInfo: ["trip" : trip])
            if CalenderHomeViewController.switchBool == false {
                CalenderHomeViewController.toggleSwitch = true
            }
        }
    }
    
    func setTripValue() -> TripModel {
        trip.tripName = tripNameTextField.text
        trip.tripStart = tripStartDestinationTextField.text
        trip.tripEnd = tripEndDestinationTextField.text
        trip.triptype = self.tripTypeResult()
        trip.cancelTrip = false
        if selectedCalenderDate != nil {
            trip.tripStartDate = selectedCalenderDate.description
            
        }else{
            trip.tripStartDate = tripStartDateInput.date.description
            
        }
        trip.tripEndDate = tripEndDateInput.date.description
        trip.tripStartTime = String(tripStartTimeInput.date.localizedDescription.split(separator: " ")[5])
        trip.tripEndTime = String(tripEndTimeInput.date.localizedDescription.split(separator: " ")[5])
        trip.notes = tableNotes
        return trip
    }
    func checkEmptyfields() -> Bool {
        if tripNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || tripStartDestinationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            tripEndDestinationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            tripNameTextField.showTextFieldError(placeholderValue: "required")
            tripStartDestinationTextField.showTextFieldError(placeholderValue: "required")
            tripEndDestinationTextField.showTextFieldError(placeholderValue: "required")
            return false
        }
        
        return true
    }
    func checkTimeAccordingToDate() -> Bool{
        let startDate = tripStartDateInput.date.description.split(separator: " ")[0]
        let endDate = tripEndDateInput.date.description.split(separator: " ")[0]
        let startTime = tripStartTimeInput.date.localizedDescription.split(separator: " ")[5]
        //.split(separator: " ")[1]
        print(startTime)
        let startTimeZone = tripStartTimeInput.date.localizedDescription.split(separator: " ")[6]
        let endTimeZone = tripEndTimeInput.date.localizedDescription.split(separator: " ")[6]
        // let endtime = tripEndTimeInput.date.description.split(separator: " ")[1]
        let endtime = tripEndTimeInput.date.localizedDescription.split(separator: " ")[5]
        print(endtime)
        //  print(tripEndTimeInput.date.localizedDescription)
        let startTimeIndex = Int(startTime.split(separator:":")[0])
        let endTimeIndex =  Int(endtime.split(separator:":")[0])
        if let startTimeInt = startTimeIndex , let endTimeInt = endTimeIndex {
            if ( startDate == endDate  && endTimeInt >= startTimeInt ) {
                if endTimeInt == startTimeInt && startTimeZone != endTimeZone {
                    return true
                }
                if endTimeInt > startTimeInt && startTimeZone == endTimeZone {
                    return true
                }
            }else if (startDate == endDate  && endTimeInt < startTimeInt && startTimeZone != endTimeZone  ){
                return true
            }
            
        }
        if startDate != endDate {
            return true
        }
        TimeErrorLabel.text = "invalid end trip time"
        TimeErrorLabel.isHidden = false
        return false
    }
    //MARK: date and time picker
    func setPicker(){
        tripStartDateInput.addTarget(self, action: #selector(setStartDate), for: .valueChanged)
        tripEndDateInput.addTarget(self, action: #selector(setEndDate), for: .valueChanged)
        tripStartTimeInput.addTarget(self, action: #selector(setStartTime), for: .valueChanged)
        tripEndTimeInput.addTarget(self, action: #selector(setEndTime), for: .valueChanged)
    }
    @objc func setStartDate(_ picker : UIDatePicker ){
        trip.tripStartDate = picker.date.description
        presentedViewController?.dismiss(animated: true, completion: nil)
  
    }
    @objc func setEndDate(_ picker : UIDatePicker ){
        trip.tripEndDate = picker.date.description
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    @objc func setStartTime(_ picker : UIDatePicker ){
        trip.tripStartTime = String(picker.date.localizedDescription.split(separator: " ")[5])
        print(picker.date.description)
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    @objc func setEndTime(_ picker : UIDatePicker ){
        trip.tripEndTime = String(picker.date.localizedDescription.split(separator: " ")[5])
        print(picker.date.description)
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
   
}
//MARK: Autocomplete
// auto complete delegate extention
extension AddNewTripViewController : GMSAutocompleteViewControllerDelegate , UITextFieldDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(String(describing: place.name))")
        print("Place coordinate: \(String(describing: place.coordinate))")
        print("Place ID: \(String(describing: place.placeID))")
        print("Place attributions: \(String(describing: place.attributions))")
        print("Place formattedAddress : \(String(describing: place.formattedAddress))")
        print("Place addressComponents : \(String(describing: place.addressComponents))")
        // Get the place name from 'GMSAutocompleteViewController'
        // Then display the name in textField
        


        if distinguishTextFields == false {
            tripStartDestinationTextField.text = place.name
        }
        if distinguishTextFields == true {
            tripEndDestinationTextField.text = place.name
        }
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
    
}
