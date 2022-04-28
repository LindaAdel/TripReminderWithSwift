//
//  EditTripViewController.swift
//  TripReminder
//
//  Created by Linda adel on 2/6/22.
//

import UIKit
import GooglePlaces

class EditTripViewController: UIViewController {
    
    var updatedTrip : TripModel?
    var updatedTripNotes : [Notes]?
    var coreDataManager : CoreDataManger?
    var distinguishTextFields : Bool?
    var oneDirectionType : Bool?
    var updateDelegate : updateTripDelegate?
    var roundType : Bool?
    
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
        setPicker()
        setUpTripDetail()
        coreDataManager = CoreDataManger()
    }
    //MARK: IBActions
    
    
    @IBAction func confirmEdit(_ sender: UIButton) {
        addNewTripInfo()
    }
    
    @IBAction func addNewNote(_ sender: UIButton) {
        newNoteAlert()
    }
    
    @IBAction func backToTripDetails(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func oneDirectionTripType(_ sender: UIButton){
        if oneDirectionType == true {
        sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        roundChecked.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            oneDirectionType = false
            roundType = true
        }else {
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            roundChecked.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            oneDirectionType = true
            roundType = false
        }
       
    }
    
    
    @IBAction func roundTripType(_ sender: UIButton) {
        if roundType == true {
        sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        oneDirectionChecked.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            roundType = false
            oneDirectionType = true
        }else {
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            oneDirectionChecked.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            roundType = true
            oneDirectionType = false
        }
    }
    
    
    func setUpTripDetail(){
        tripNameTextField.text = updatedTrip?.tripName
        tripStartDestinationTextField.text = updatedTrip?.tripStart
        tripEndDestinationTextField.text = updatedTrip?.tripEnd
        if let startDate = updatedTrip?.tripStartDate?.split(separator: " ")[0]
           ,let endDate = updatedTrip?.tripEndDate?.split(separator: " ")[0],
           let startTime = updatedTrip?.tripStartTime,
           let endTime = updatedTrip?.tripEndTime
        {
          
            if let pickerStartDate = dateFormatter(with: String(startDate)) ,
               let pickerEndDate = dateFormatter(with: String(endDate)) ,
               let pickerStartTime = timeFormatter(with: startTime),
               let pickerEndTime = timeFormatter(with: endTime)
               {
                tripStartDateInput.date = pickerStartDate
                tripEndDateInput.date = pickerEndDate
                tripStartTimeInput.date = pickerStartTime
                tripEndTimeInput.date = pickerEndTime
            }
            updatedTripNotes = updatedTrip?.notes
        }
        if updatedTrip?.triptype == "oneDirection" {
            oneDirectionType = true
            roundType = false
            oneDirectionChecked.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            roundChecked.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
        else if updatedTrip?.triptype == "Round" {
            oneDirectionType = false
            roundType = true
            roundChecked.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            oneDirectionChecked.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
    }
    func dateFormatter(with sDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.isLenient = true
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: sDate) {
            return date
            
        }else{
            return nil
        }
        
    }
    func timeFormatter(with sTime: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.isLenient = true
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "HH:mm:ss"
        if let date = dateFormatter.date(from: sTime) {
            return date
            
        }else{
            return nil
        }
        
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
    func addNewTripInfo(){
        if checkEmptyfields() && checkTimeAccordingToDate() {
            if let trip = setTripValue(){
                coreDataManager?.updateTrip(with: trip.localTripId!, and: trip)
                updateDelegate?.replaceUpdatedTrip(trip: trip)
                dismiss(animated: true, completion: nil)
                //notification for each time a trip is added aka posted
                NotificationCenter.default.post(name: NSNotification.Name("tripAdded"), object: nil , userInfo: ["trip" : trip])
                if CalenderHomeViewController.switchBool == false {
                    CalenderHomeViewController.toggleSwitch = true
                }
            }
            }
          
    }
    func tripTypeResult() -> String {
        if oneDirectionType == true {
            return "oneDirection"
        }
        if roundType  == true {
            return "Round"
        }
        return "oneDirection"
    }
    func setTripValue() -> TripModel? {
        updatedTrip?.tripName = tripNameTextField.text
        updatedTrip?.tripStart = tripStartDestinationTextField.text
        updatedTrip?.tripEnd = tripEndDestinationTextField.text
        updatedTrip?.triptype = self.tripTypeResult()
        updatedTrip?.cancelTrip = false
        updatedTrip?.tripStartDate = tripStartDateInput.date.description
        updatedTrip?.tripEndDate = tripEndDateInput.date.description
        updatedTrip?.tripStartTime = String(tripStartTimeInput.date.localizedDescription.split(separator: " ")[5])
        updatedTrip?.tripEndTime = String(tripEndTimeInput.date.localizedDescription.split(separator: " ")[5])
        updatedTrip?.notes = updatedTripNotes
        return updatedTrip
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
        updatedTrip?.tripStartDate = picker.date.description
        presentedViewController?.dismiss(animated: true, completion: nil)
  
    }
    @objc func setEndDate(_ picker : UIDatePicker ){
        updatedTrip?.tripEndDate = picker.date.description
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    @objc func setStartTime(_ picker : UIDatePicker ){
        updatedTrip?.tripStartTime = String(picker.date.localizedDescription.split(separator: " ")[5])
        print(picker.date.description)
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    @objc func setEndTime(_ picker : UIDatePicker ){
        updatedTrip?.tripEndTime = String(picker.date.localizedDescription.split(separator: " ")[5])
        print(picker.date.description)
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

extension EditTripViewController : UITableViewDelegate , UITableViewDataSource{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return updatedTripNotes!.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesDetailCell", for: indexPath)
            let note = updatedTripNotes?[indexPath.row]
            cell.textLabel?.text = note?.title
            if let noteStatus = note?.isOpened{
                
                cell.accessoryType = noteStatus ? .checkmark : .none
            }
            
            return cell
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let note = updatedTripNotes?[indexPath.row]
            viewNotes(note: note!)
            note?.isOpened = true
            tableView.reloadData()
        }
        
        // Override to support conditional editing of the table view.
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the specified item to be editable.
            return true
        }
        
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Delete the row from the data source
                let note = updatedTripNotes?[indexPath.row]
                // update firebas
                // update ui
                updatedTripNotes?.remove(at: indexPath.row )
                updatedTrip?.notes = updatedTripNotes
                if let noteTrip = updatedTrip , let notesArray = updatedTripNotes {
                    NotificationCenter.default.post(name: NSNotification.Name("noteDeleted"), object: nil , userInfo: ["trip" : noteTrip , "notes" : notesArray ])}
                coreDataManager?.deleteNote(noteId: (note?.noteId!)!)
                tableView.reloadData()
                
            }
        }
        func viewNotes(note : Notes){
            let alert = UIAlertController(title: note.title, message: note.body, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
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
        updatedTripNotes?.removeAll {
            $0.noteId == note.noteId
        }
        updatedTripNotes?.append(note)
    
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
            self.updatedTripNotes!.append(newNote)
            self.notesList.reloadData()
  }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
       
    }
    
//MARK: Autocomplete
// auto complete delegate extention
extension EditTripViewController : GMSAutocompleteViewControllerDelegate , UITextFieldDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
      
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

