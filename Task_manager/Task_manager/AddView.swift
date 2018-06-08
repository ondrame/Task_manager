//
//  AddView.swift
//  Task_manager
//
//  Created by Ondřej Měchura on 01.06.18.
//  Copyright © 2018 Ondřej Měchura. All rights reserved.
//

import UIKit
import CoreData

class AddView: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var addButtonOutlet: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var colorPicker: UIView!
    
    let red_button:UIButton = UIButton()
    let blue_button:UIButton = UIButton()
    let green_button:UIButton = UIButton()
    let yellow_button:UIButton = UIButton()
    let black_button:UIButton = UIButton()
    
    var language:String = ""
    
    var selected_color:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.language = getLanguage()
        
        notesTextView.delegate = self
        
        self.titleTextField.layer.borderWidth = 1
        self.titleTextField.layer.borderColor = UIColor.lightGray.cgColor
        
       
        
        switch language {
        case "cz":self.notesTextView.text = "Napište poznámku (volitelné)"
            self.addButtonOutlet.setTitle("Přidat", for: .normal)
            self.titleTextField.placeholder = "Napište popisek"
            self.navBar.topItem?.title = "Přidat poznámku"
        case "en": self.notesTextView.text = "Enter notes (optional)"
            self.addButtonOutlet.setTitle("Add", for: .normal)
            self.titleTextField.placeholder = "Enter a title"
           self.navBar.topItem?.title = "Add a note"
        default:
            break
        }
        
        
        
        self.notesTextView.textColor = UIColor.lightGray
        
        self.notesTextView.layer.borderWidth = 1
        self.notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        loadColorPicker()

    } // end of viewDidLoad


    
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        
        
        if notesTextView.text! == "Enter notes (optional)" || notesTextView.text! == "Napište poznámku (volitelné)"{
            
            notesTextView.text = ""
            notesTextView.textColor = UIColor.black
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if notesTextView.text == ""{
            
            switch self.language {
            case "cz":self.notesTextView.text = "Napište poznámku (volitelné)"
            case "en": self.notesTextView.text = "Enter notes (optional)"
            default:
                break
            }
            notesTextView.textColor = UIColor.lightGray
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
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
  
    
    
    
    
    
    @IBAction func AddAction(_ sender: Any) {
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let title = self.titleTextField.text
        let notes = self.notesTextView.text
        let id = generateID()
        let day:String = "\(components.day!)"
        let month:String = "\(components.month!)"
        let year:String = "\(components.year!)"
        let locked:Bool = false
        let method:String = ""
        let password:String = ""
        if title != ""{
            
            addToCoreData(id: id, title: title!, notes: notes!, day: day, month: month, year: year, color: self.selected_color, locked: locked, method: method, password: password)
            self.dismiss(animated: true, completion: nil)
        
        }else{
            print("title is missing")
        }
   
    }
    
    
    
    
    private func addToCoreData(id:String, title:String, notes:String, day:String, month:String, year:String, color:String, locked:Bool, method:String, password:String){
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let note = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context)
        
        
        
        print(locked)
        
        
        
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
            print("saving note failed")
        }
        
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
        
    }
    
  
    
    
    
} // end of class
