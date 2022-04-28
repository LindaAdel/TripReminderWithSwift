//
//  TripDetailsViewController.swift
//  TripReminder
//
//  Created by Linda adel on 12/24/21.
//

import UIKit
import Firebase

class TripDetailsViewController: UIViewController , updateTripDelegate {
  
    var trip : TripModel!
    var notes : [Notes]!
    var notesAfterDelete : [Notes] = []
    var firebaseManger : FirebaseManger!
    var coreDataManger : CoreDataManger!
    var updatedTrip : updateTripDelegate?
    var replacedNotes : AddTripDelegate!
    //MARK: IBOutlets
    @IBOutlet weak var tripNameLabel: UILabel!
    
    @IBOutlet weak var tripStartDestinationLabel: UILabel!
    
    @IBOutlet weak var tripEndDestinationLabel: UILabel!
    
    @IBOutlet weak var tripTypeLabel: UILabel!
    
    @IBOutlet weak var tripStartDate: UILabel!
    
    @IBOutlet weak var tripEndDate: UILabel!
    
    
    @IBOutlet weak var tripStartTime: UILabel!
    
    @IBOutlet weak var tripEndTime: UILabel!
    
    @IBOutlet weak var tripNotesList: UITableView!{
        didSet{
            tripNotesList.delegate = self
            tripNotesList.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManger = FirebaseManger.shared
        coreDataManger = CoreDataManger()
      
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        setUpTripDetail()
    }
    override func viewDidDisappear(_ animated: Bool) {
        notes.removeAll()
    }
    //MARK: IBActions
    
    @IBAction func backToHome(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        updatedTrip?.replaceUpdatedTrip(trip: trip)
    }
    
    
    @IBAction func editTrip(_ sender: UIBarButtonItem) {
        if let editTripVC = self.storyboard?.instantiateViewController(withIdentifier: "editTrip") as? EditTripViewController
        {
           
            editTripVC.updatedTrip = trip
            editTripVC.updateDelegate = self
            editTripVC.modalPresentationStyle = .fullScreen
            self.present(editTripVC, animated: true, completion: nil)
            
        }
    }
    //MARK: Update Trip delegate
    func replaceUpdatedTrip(trip: TripModel) {
        self.trip = trip
       tripNotesList.reloadData()
    }
    
   
}
extension TripDetailsViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesDetailCell", for: indexPath)
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        if let noteStatus = note.isOpened{
            
            cell.accessoryType = noteStatus ? .checkmark : .none
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        viewNotes(note: note)
        note.isOpened = true
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
            let note = notes[indexPath.row]
            // update firebas
            // update ui
            notes.remove(at: indexPath.row )
            trip.notes = notes
          //  firebaseManger.removeNoteFromFirebase( trip: trip, notes: notes)
            if let noteTrip = trip , let notesArray = notes {
                NotificationCenter.default.post(name: NSNotification.Name("noteDeleted"), object: nil , userInfo: ["trip" : noteTrip , "notes" : notesArray ])}
            coreDataManger.deleteNote(noteId: note.noteId!)
            replacedNotes.replaceModifiedTrip(trip: trip)
            tripNotesList.reloadData()
            
        }
    }
    func viewNotes(note : Notes){
        let alert = UIAlertController(title: note.title, message: note.body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func setUpTripDetail(){
        tripNameLabel.text = trip.tripName
        tripStartDestinationLabel.text = trip.tripStart
        tripEndDestinationLabel.text = trip.tripEnd
        //  tripTypeLabel.text = trip.triptype.map { $0.rawValue }
        tripTypeLabel.text = trip.triptype?.description
        if let startDate = trip.tripStartDate?.split(separator: " ")[0]
           //,let startTime = trip.tripStartTime?.split(separator: " ")[1]
           ,let endDate = trip.tripEndDate?.split(separator: " ")[0]
        //, let endTime = trip.tripEndTime?.split(separator: " ")[1]
        {
            tripStartDate.text = String(startDate)
            tripEndDate.text = String(endDate)
            // tripStartTime.text = String(startTime)
            // tripEndTime.text = String(endTime)
            tripStartTime.text = trip.tripStartTime
            tripEndTime.text = trip.tripEndTime
        }
        notes = trip.notes
        tripNotesList.reloadData()
    }
}
