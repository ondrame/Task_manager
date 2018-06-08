//
//  DetailView.swift
//  Task_manager
//
//  Created by Ondřej Měchura on 01.06.18.
//  Copyright © 2018 Ondřej Měchura. All rights reserved.
//

import UIKit
import CoreData

class DetailView: UIViewController, UITextViewDelegate {

    
    var id:String?
    var name:String?
    var notes:String?
    var locked:Bool?
    var method:String?
    var password:String?
    
    
    let red_button:UIButton = UIButton()
    let blue_button:UIButton = UIButton()
    let green_button:UIButton = UIButton()
    let yellow_button:UIButton = UIButton()
    let black_button:UIButton = UIButton()
    var selected_color:String = ""
    
    
    @IBOutlet weak var colorPicker: UIView!
    
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var noteTextfield: UITextView!
    
    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var notesOutlet: UILabel!
    
    
    @IBOutlet weak var lockSwitchOutlet: UISwitch!
    @IBOutlet weak var lockLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noteTextfield.delegate = self
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
      
        
        self.titleTextField.text = name
        self.noteTextfield.text = notes
        
        
        self.titleTextField.isUserInteractionEnabled = true
        self.noteTextfield.isUserInteractionEnabled = true
        self.noteTextfield.isEditable = true
        
        
        
 
        
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.black.cgColor
        
        noteTextfield.layer.borderWidth = 1
        noteTextfield.layer.borderColor = UIColor.black.cgColor
       
        
        self.navigationItem.title = self.name
        
        let language:String = getLanguage()
        
        switch language {
        case "cz": titleOutlet.text = "Popisek"
            notesOutlet.text = "Poznámka"
        case "en":titleOutlet.text = "Title"
            notesOutlet.text = "Notes"
        default:
            break
        }
      
        loadColorPicker()
        
        
        switch selected_color {
        case "red":red_button.layer.borderWidth = 4
            red_button.layer.borderColor = UIColor.white.cgColor
            
        case "yellow":yellow_button.layer.borderWidth = 4
            yellow_button.layer.borderColor = UIColor.white.cgColor
            
        case "green":green_button.layer.borderWidth = 4
            green_button.layer.borderColor = UIColor.white.cgColor
            
        case "blue":blue_button.layer.borderWidth = 4
            blue_button.layer.borderColor = UIColor.white.cgColor
            
        case "black":black_button.layer.borderWidth = 4
            black_button.layer.borderColor = UIColor.white.cgColor
          
        default:
            break
        }
        
        self.lockSwitchOutlet.isOn = self.locked!
        
        if self.locked!{
            if language == "cz"{
                self.lockLabel.text = "Odemknout poznámku"
            }else{
                 self.lockLabel.text = "Unlock note"
            }
            
            
            
           
        }else{
            if language == "cz"{
                self.lockLabel.text = "Uzamknout poznámku"
            }else{
                   self.lockLabel.text = "Lock note"
            }
           
            
         
        }
        
        
        
        
        
    } // end of viewDidLoad
    
    
  
    
    
   
    @IBAction func titleChanged(_ sender: Any) {
      updateData()
        self.navigationItem.title = self.titleTextField.text
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
      updateData()
    }
    
    
    
    @IBAction func title_textfield_tapped(_ sender: Any) {
     let language:String = getLanguage()
        var title:String = ""
        switch language {
        case "cz":title = "Zrušit"
        case "en":title = "Cancel"
        default:
            break
        }
          self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(dismissKeyboard))
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        var title:String = ""
        let language:String = getLanguage()
        switch language {
        case "cz": title = "Zrušit"
        case "en": title = "Cancel"
        default:
            break
        }
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(dismissKeyboard))
    }
    
    
    
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
        self.navigationItem.rightBarButtonItem = nil
    }
    
    private func updateData(){
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let id:String = generateID()
        let title:String = titleTextField.text!
        let note:String = noteTextfield.text!
        let day:String = "\(components.day!)"
        let month:String = "\(components.month!)"
        let year:String = "\(components.year!)"
        let color:String = self.selected_color
        let locked:Bool = self.locked!
        let method = self.method
        let password = self.password
        
        print(locked)
    
        
        deleteFromCoreData(id: self.id!)
        self.id = id
        addToCoreData(id: id, title: title, notes: note, day: day, month: month, year: year, color: color, locked: locked, method: method!, password: password!)
        
        
        
        
    }
    
    
    
    
    private func deleteFromCoreData(id:String){
        
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.includesPropertyValues = false
        do{
            let items = try context.fetch(request)
            for s in items as! [NSManagedObject]{
                let k = s.value(forKey: "id") as! String
                if k == id{
                    context.delete(s as! NSManagedObject)
                }
            }
            try context.save()
            
        }catch{
            print("Can not delete item from core data")
        }
        
    }
    
    
    private func addToCoreData(id:String, title:String, notes:String, day:String, month:String, year:String, color:String, locked:Bool, method:String, password:String){
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let note = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context)
        note.setValue(id, forKey: "id")
        note.setValue(title, forKey: "title")
        note.setValue(notes, forKey: "note")
        note.setValue(day, forKey: "day")
        note.setValue(month, forKey: "month")
        note.setValue(year, forKey: "year")
        note.setValue(color, forKey: "color")
        note.setValue(locked, forKey: "locked")
        note.setValue(method, forKey: "method")
        note.setValue(password, forKey: "password")
        do{
            try context.save()
        }catch{
            print("Detail view : saving to core data failed")
        }
    }
    
    
    
  
    private func generateID() -> String{
        var id:String = ""
        for i in 1...10 {
            let num = Int(arc4random_uniform(9) + 1)
            id = id + "\(num)"
        }
        return id
    }
    
    
    private func getLanguage() -> String{
        var language:String = ""
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Language")
        do{
            let results = try context.fetch(request)
            for s in results as! [NSManagedObject]{
                if let k = s.value(forKey: "language"){
                    language = k as! String
                }
            }
        }catch{
            print("Can not get language from core data")
            
        }
        return language
    }
    
    
    
    @IBAction func lockSwitchAction(_ sender: UISwitch) {
        
        
        
        let language = getLanguage()
        
        
        
        
        
        
        if self.lockSwitchOutlet.isOn{
          
            var title:String = ""
            var message:String = ""
            var lock:String = ""
            
            switch(language){
                
            case "cz": title = "Uzamknout poznámku"
                message = "Uzamčení zajistí zabezpečení Vaší poznámky"
                lock = "Odemknout poznámku"
            case "en": title = "Lock a note"
                message = "This feature will improve a secure of your note"
                lock = "Unlock note"
                
            default:break
            }
            
            let lockAlert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            let touchID = UIAlertAction(title: "TouchID", style: .default) { (action) in
                self.locked = true
                self.method = "touchID"
                self.password = ""
                self.updateData()
                self.lockLabel.text = lock
                
            }
            var a:String = ""
            var b:String = ""
            var c:String = ""
            var d:String = ""
            var e:String = ""
            var f:String = ""
            var g:String = ""
           
            
            switch (language){
                
            case "cz": a = "Heslo"
            b  = "Zde mužete uzamknout poznámku pomocí hesla"
                c = "Prosím, zadejte heslo"
                d = "Potvrďte heslo"
                e = "Potvrdit"
                f = "Zrušit"
                g = "Odemknout poznámku"

                
            case "en": a = "Password"
                b = "You can secure your note with a password here."
                c = "Please, enter a password"
                d = "Confirm a password"
                e = "Confirm"
                f = "Cancel"
                g = "Unlock a note"
              
            default:break
            }
            
            
            
            
            
            let password = UIAlertAction(title: a, style: .default) { (action) in
                
                let passwordAlert = UIAlertController(title: a, message: b, preferredStyle: .alert)
                
               passwordAlert.addTextField { (textfield: UITextField) in
                    textfield.placeholder = c
                    
                }
                passwordAlert.addTextField { (textfield: UITextField) in
                    textfield.placeholder = d
                    
                }
                
                
                passwordAlert.addAction(UIAlertAction(title: e, style: .default, handler: { (action) in
                    
                    if passwordAlert.textFields![0].text == passwordAlert.textFields![1].text{
                        self.method = "password"
                        self.password = passwordAlert.textFields![0].text
                        self.locked = true
                        self.updateData()
                        self.lockLabel.text = g
                        
                    }
                    
                }))
                
                
                passwordAlert.addAction(UIAlertAction(title: f, style: .destructive, handler: { (action) in
                    passwordAlert.dismiss(animated: true, completion: nil)
                    self.lockSwitchOutlet.isOn = false
                }))
                
              
              
                
                self.present(passwordAlert, animated: true, completion: nil)
                
                
                
                
            }
            
            let cancel = UIAlertAction(title: f, style: .cancel) { (action) in
                self.lockSwitchOutlet.isOn = false
                lockAlert.dismiss(animated: true, completion: nil)
            }
            
            lockAlert.addAction(touchID)
            lockAlert.addAction(password)
            lockAlert.addAction(cancel)
            
            self.present(lockAlert, animated: true, completion: nil)
         }else{
            
            var text:String = ""
            let language = getLanguage()
            
            switch(language){
            case "cz":text = "Uzamknout poznámku"
            case "en": text = "Lock a note"
                
                
            default:break
            }
            
            
            
          self.locked = false
            self.method = ""
            self.password = ""
            self.updateData()
            self.lockLabel.text = text
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    private func loadColorPicker(){
        
        green_button.frame = CGRect(x: UIScreen.main.bounds.width / 2 - green_button.frame.width / 2, y: colorPicker.frame.height / 2 - 20 , width: 40, height: 40)
        green_button.layer.cornerRadius = 0.5 * green_button.bounds.size.width
        green_button.clipsToBounds = true
        green_button.addTarget(self, action: #selector(green_button_action), for: .touchUpInside)
        green_button.center.x =  UIScreen.main.bounds.width / 2
        
        yellow_button.frame = CGRect(x: 0, y: colorPicker.frame.height / 2 - 20, width: 40, height: 40)
        yellow_button.layer.cornerRadius = 0.5 * yellow_button.bounds.size.width
        yellow_button.clipsToBounds = true
        yellow_button.addTarget(self, action: #selector(yellow_button_Action), for: .touchUpInside)
        yellow_button.center.x = UIScreen.main.bounds.width / 2 - 50
        
        red_button.frame = CGRect(x: 0, y: colorPicker.frame.height / 2 - 20, width: 40, height: 40)
        red_button.layer.cornerRadius = 0.5 * red_button.bounds.size.width
        red_button.clipsToBounds = true
        red_button.addTarget(self, action: #selector(red_button_action), for: .touchUpInside)
        red_button.center.x = UIScreen.main.bounds.width / 2 - 100
        
        blue_button.frame = CGRect(x: 0, y: colorPicker.frame.height / 2 - 20, width: 40, height: 40)
        blue_button.layer.cornerRadius = 0.5 * blue_button.bounds.size.width
        blue_button.clipsToBounds = true
        blue_button.addTarget(self, action: #selector(blue_button_action), for: .touchUpInside)
        blue_button.center.x = UIScreen.main.bounds.width / 2 + 50
        
        black_button.frame = CGRect(x: 0, y: colorPicker.frame.height / 2 - 20, width: 40, height: 40)
        black_button.layer.cornerRadius = 0.5 * black_button.bounds.size.width
        black_button.clipsToBounds = true
        black_button.addTarget(self, action: #selector(black_button_action), for: .touchUpInside)
        black_button.center.x = UIScreen.main.bounds.width / 2 + 100
        
        
        
        
        green_button.backgroundColor = UIColor.green
        yellow_button.backgroundColor = UIColor.yellow
        red_button.backgroundColor = UIColor.red
        blue_button.backgroundColor = UIColor.blue
        black_button.backgroundColor = UIColor.black
        
        colorPicker.addSubview(green_button)
        colorPicker.addSubview(yellow_button)
        colorPicker.addSubview(red_button)
        colorPicker.addSubview(blue_button)
        colorPicker.addSubview(black_button)
        
        
    }
    
    @objc func red_button_action(){
        red_button.layer.borderWidth = 4
        red_button.layer.borderColor = UIColor.white.cgColor
        switch self.selected_color {
        case "": selected_color = "red"
            
        case "green": green_button.layer.borderWidth = 0
        selected_color = "red"
        case "yellow": yellow_button.layer.borderWidth = 0
        selected_color = "red"
        case "red": red_button.layer.borderWidth = 0
        selected_color = ""
        case "blue": blue_button.layer.borderWidth = 0
        selected_color = "red"
        case "black": black_button.layer.borderWidth = 0
        selected_color = "red"
        default:
            break
        }
        updateData()
    }
    @objc func yellow_button_Action(){
        yellow_button.layer.borderWidth = 4
        yellow_button.layer.borderColor = UIColor.white.cgColor
        
        switch self.selected_color {
        case "": selected_color = "yellow"
            
        case "green": green_button.layer.borderWidth = 0
        selected_color = "yellow"
        case "yellow": yellow_button.layer.borderWidth = 0
        selected_color = ""
        case "red": red_button.layer.borderWidth = 0
        selected_color = "yellow"
        case "blue": blue_button.layer.borderWidth = 0
        selected_color = "yellow"
        case "black": black_button.layer.borderWidth = 0
        selected_color = "yellow"
        default:
            break
        }
        
        updateData()
    }
    @objc func green_button_action(){
        green_button.layer.borderWidth = 4
        green_button.layer.borderColor = UIColor.white.cgColor
        
        
        switch self.selected_color {
        case "": selected_color = "green"
            
        case "green": green_button.layer.borderWidth = 0
        selected_color = ""
        case "yellow": yellow_button.layer.borderWidth = 0
        selected_color = "green"
        case "red": red_button.layer.borderWidth = 0
        selected_color = "green"
        case "blue": blue_button.layer.borderWidth = 0
        selected_color = "green"
        case "black": black_button.layer.borderWidth = 0
        selected_color = "green"
        default:
            break
        }
        
        updateData()
        
    }
    @objc func blue_button_action(){
        blue_button.layer.borderWidth = 4
        blue_button.layer.borderColor = UIColor.white.cgColor
        
        
        switch self.selected_color {
        case "": selected_color = "blue"
            
        case "green": green_button.layer.borderWidth = 0
        selected_color = "blue"
        case "yellow": yellow_button.layer.borderWidth = 0
        selected_color = "blue"
        case "red": red_button.layer.borderWidth = 0
        selected_color = "blue"
        case "blue": blue_button.layer.borderWidth = 0
        selected_color = ""
        case "black": black_button.layer.borderWidth = 0
        selected_color = "blue"
        default:
            break
        }
        updateData()
        
        
    }
    @objc func black_button_action(){
        black_button.layer.borderWidth = 4
        black_button.layer.borderColor = UIColor.white.cgColor
        
        
        switch self.selected_color {
        case "": selected_color = "black"
            
        case "green": green_button.layer.borderWidth = 0
        selected_color = "black"
        case "yellow": yellow_button.layer.borderWidth = 0
        selected_color = "black"
        case "red": red_button.layer.borderWidth = 0
        selected_color = "black"
        case "blue": blue_button.layer.borderWidth = 0
        selected_color = "black"
        case "black": black_button.layer.borderWidth = 0
        selected_color = ""
        default:
            break
        }
        updateData()
    }
    

    
    
    
    
    
    
    
    
    
    
    

} // end of class







