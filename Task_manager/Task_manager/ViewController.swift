//
//  ViewController.swift
//  Task_manager
//
//  Created by Ondřej Měchura on 01.06.18.
//  Copyright © 2018 Ondřej Měchura. All rights reserved.
//

import UIKit
import CoreData
import EmptyDataSet_Swift
import LocalAuthentication

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    
  
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var searchTextfield: UITextField!
    
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    @IBOutlet weak var languageSwitchOutlet: UIBarButtonItem!
    
    
    var tasks = [Note]()
    var searchingData = [Note]()
    
    var isSearching = false
    

   

    
    
    var loaded:Bool = false
    
    
    
    override func viewDidLoad() {

     
     
        super.viewDidLoad()
        
        self.TableView.delegate = self
        self.TableView.dataSource = self
        self.loadTasks()
    
      TableView.emptyDataSetSource = self
        TableView.emptyDataSetDelegate = self
        
        TableView.tableFooterView = UIView()
      
        let languageIsSet = checkLanguage()
        
        if !languageIsSet{
            setLanguage()
        }
        
        
        let language = getLanguage()
        
    
        
        switch language {
        case "cz":self.navigationItem.title = "Moje poznámky"
            self.searchTextfield.placeholder = "Hledat..."
            self.addButtonOutlet.setTitle("Přidat poznámku", for: .normal)
      
      
            self.languageSwitchOutlet.image = UIImage(named: "USA_flag")?.withRenderingMode(.alwaysOriginal)
    
            
        case "en": self.navigationItem.title = "My notes"
            self.searchTextfield.placeholder = "Search..."
            self.addButtonOutlet.setTitle("Add a note", for: .normal)
            self.languageSwitchOutlet.image = UIImage(named: "Czechia_flag")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        default:
            break
        }
        
        
        
     
        
    } // end of viewDidLoad
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if self.loaded{
            self.tasks.removeAll()
            self.loadTasks()
       
                   self.TableView.reloadData()
           
         
        }else{
            self.loaded = true
        }
    }
    
 
    
  
   
    
    @IBAction func AddAction(_ sender: Any) {
        
        let sb:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:UIViewController = sb.instantiateViewController(withIdentifier: "AddView")
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    private func loadTasks(){
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
        
        do{
            let results = try context.fetch(request)
            
            if results.count > 0{
                
                for s in results as! [NSManagedObject]{
                    let id = s.value(forKey: "id")
                    let title = s.value(forKey: "title")
                    let note = s.value(forKey: "note")
                    let day = s.value(forKey: "day")
                    let month = s.value(forKey: "month")
                    let year = s.value(forKey: "year")
                    let color = s.value(forKey: "color")
                    let locked = s.value(forKey: "locked")
                    let method = s.value(forKey: "method")
                    let password = s.value(forKey: "password")
                 
                
                    let task = Note(id: id as! String,title: title as! String,notes: note as! String,day: day as! String,month: month as! String,year: year as! String,color: color as! String,locked: locked as! Bool ,method: method as! String,password: password as! String)
                    
                    self.tasks.append(task)
                }
            }
        }catch{
            print("Can not get tasks from core data")
        }
    }
    
    
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching{
            return searchingData.count
        }
        
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier:String = "BasicCell"
        let myCell: customCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! customCell
        
         let item:Note
        if isSearching{
            item = searchingData[indexPath.row]
        }else{
            item = tasks[indexPath.row]
        }
        let day = item.day as! String
        let month = item.month as! String
        let year = item.year as! String
        
        let date:String = day + "." + month + "." + year
       
        
        myCell.titleLabel.text = item.title
        myCell.dateLabel.text = date
        
        
        switch item.color {
        case "": myCell.colorLabel.backgroundColor = UIColor.white
        case "red":myCell.colorLabel.backgroundColor = UIColor.red
        case "yellow":myCell.colorLabel.backgroundColor = UIColor.yellow
        case "green": myCell.colorLabel.backgroundColor = UIColor.green
        case "blue":myCell.colorLabel.backgroundColor = UIColor.blue
        case "black":myCell.colorLabel.backgroundColor = UIColor.black
        default:
            break
        }
        
  
        myCell.colorLabel.layer.cornerRadius = 0.5 * myCell.colorLabel.bounds.size.width
        myCell.colorLabel.clipsToBounds = true
        
        
        
        return myCell
    }
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var item:Note
        
        if isSearching{
           item = searchingData[indexPath.row]
        }else{
            item = tasks[indexPath.row]
        }
        
        let sb:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:DetailView = sb.instantiateViewController(withIdentifier: "DetailView") as! DetailView
         vc.id = item.id
        vc.name = item.title
        vc.notes = item.notes
        vc.selected_color = item.color
        vc.locked = item.locked
        vc.method = item.method
        vc.password = item.password
        
        let locked:Bool = item.locked!
        let method:String = item.method
        let password:String = item.password
        
        if locked{
            
            switch(method){
                
            case "password":
                let language = getLanguage()
                var head_title = ""
                var message = ""
                var placeholder = ""
                var confirm = ""
                var cancel = ""
                
                switch(language){
                case "cz":head_title = "Tato poznámka je chráněna heslem"
                    message = "Pro odemčení prosím zadejte heslo"
                    placeholder = "Prosím, zadejte heslo"
                    confirm = "Potvrdit"
                    cancel = "Zrušit"
                case "en": head_title = "This note is protected with password"
                    message = "Please, enter a password for unlock"
                    placeholder = "Please, enter a password"
                    confirm = "Confirm"
                    cancel = "Cancel"
                default:break
                }
                
                let passAlert = UIAlertController(title: head_title, message: message, preferredStyle: .alert)
                
            passAlert.addTextField { (textfield: UITextField) in
                textfield.placeholder = placeholder
                
                }
                
            passAlert.addAction(UIAlertAction(title: confirm, style: .default, handler: { (action) in
                
                if passAlert.textFields![0].text == password{
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                  
                }
            }))
            passAlert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { (action) in
                passAlert.dismiss(animated: true, completion: nil)
            }))
                self.present(passAlert, animated: true, completion: nil)
            case "touchID":
                let language = getLanguage()
                var reason = ""
                
                switch (language){
                case "cz": reason = "Prosím, prokažte svou totožnost pomocí TouchID, nebo FaceID"
                case "en": reason = "Please, use your finger print or face to view your note"
                default:break
                }
                let context:LAContext = LAContext()
                if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
                {
                    context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason, reply: {(wasSuccesful, error) in
                        
                        if wasSuccesful{
                            DispatchQueue.main.async {
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }else{
                        }
                    })
                    
                }
            default: break
            }
        }else{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
    var actions = [UITableViewRowAction]()
        
        var item:Note
        
        let language:String = getLanguage()
        
        var delete_title:String = ""
        var lock_title:String = ""
        
        switch language {
        case "cz":delete_title = "Smazat"
            lock_title = "Uzamknout"
            
        case "en": delete_title = "Delete"
           lock_title = "Lock"
        default:
            break
        }
        
        if isSearching{
            item = searchingData[indexPath.row]
        }else{
            item = tasks[indexPath.row]
        }
        
        let delete = UITableViewRowAction(style: .destructive, title: delete_title) { (action, indexPAth) in
            
            var reason:String = ""
            var title:String = ""
            var message:String = ""
            var placeholder:String = ""
            var confirm:String = ""
            var cancel:String = ""
            
            switch(language){
            case "cz": reason = "Pro smazání poznámky prosím prokažte svou totožnost pomocí TouchID, nebo FaceID"
                title = "Tato poznámka je chráněna heslem"
                message = "Pro smazání poznámky prosím zadejte heslo"
                placeholder = "Prosím, zadejte heslo"
                confirm = "Potvrdit"
                cancel = "Zrušit"
                
            case "en": reason = "Please, use TouchID, or FaceID to delete this note"
                title = "This note is protected with password"
                message = "Please, enter password to delete this note"
                placeholder = "Please, enter a password"
                confirm = "Confirm"
                cancel = "Cancel"
                
            default:break
            }
            
            
            if item.locked!{
                
                switch (item.method){
                case "touchID":   let context:LAContext = LAContext()
                if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
                {
                    context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason, reply: {(wasSuccesful, error) in
                        
                        if wasSuccesful{
                            DispatchQueue.main.async {
                                let id = self.tasks[indexPAth.row].id
                                self.deleteFromCoreData(id: id!)
                                self.tasks.remove(at: indexPAth.row)
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    tableView.deleteRows(at: [indexPAth], with: .fade)
                                }, completion: { (completed) in
                                    tableView.reloadData()
                                })}
                        }else{
                            
                        }
                        
                    })
                    }
                case "password":
                    let passwordAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    passwordAlert.addTextField { (textfield: UITextField) in
                        textfield.placeholder = placeholder
                    }
                    passwordAlert.addAction(UIAlertAction(title: confirm, style: .default, handler: { (action) in
                        if passwordAlert.textFields![0].text == item.password{
                            DispatchQueue.main.async {
                                let id = self.tasks[indexPAth.row].id
                                self.deleteFromCoreData(id: id!)
                                self.tasks.remove(at: indexPAth.row)
                                
                                UIView.animate(withDuration: 0.1, animations: {
                                    tableView.deleteRows(at: [indexPAth], with: .fade)
                                }, completion: { (completed) in
                                    tableView.reloadData()
                                })}
                        }else{
                            print("Wrong password")
                        }
                    }))
                    passwordAlert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { (action) in
                        passwordAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(passwordAlert, animated: true, completion: nil)
              default:break
                }
            }else{
              
                    let id = self.tasks[indexPAth.row].id
                    self.deleteFromCoreData(id: id!)
                    self.tasks.remove(at: indexPAth.row)
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        tableView.deleteRows(at: [indexPAth], with: .fade)
                    }, completion: { (completed) in
                        tableView.reloadData()
                    })
            }
        }
        actions.append(delete)
        
        
        if !item.locked!{
            
        
        
        let lock = UITableViewRowAction(style: .default, title: lock_title) { (action, indexPAth) in
            
            let alert = UIAlertController(title: "Lock your note", message: "I wish to lock this note with : ", preferredStyle: .actionSheet)
            
            let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            })
            
            
            let passwordAction = UIAlertAction(title: "Password", style: .default, handler: { (action) in
                
                let passwordAlert = UIAlertController(title: "Set your code", message: "Set code for your note", preferredStyle: .alert)
                
               
                
                passwordAlert.addTextField { (textfield: UITextField) in
                    textfield.placeholder = "Password"
                }
                passwordAlert.addTextField { (textfield: UITextField) in
                    textfield.placeholder = "Confirm password"
                }
                
                
                let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
                    
                    let pass = passwordAlert.textFields![0].text
                    let re_pass = passwordAlert.textFields![1].text
                    
                    if pass == re_pass{
                        if self.isSearching{
                            self.secureNote(id: self.searchingData[indexPAth.row].id!, method: "password", password: pass!, lock: true)
                        }else{
                            self.secureNote(id: self.tasks[indexPAth.row].id!, method: "password", password: pass!, lock: true)
                        }
                    }else{
                        print("wrong password")
                    }
                    
                })
                
                passwordAlert.addAction(confirmAction)
                
                passwordAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                    passwordAlert.dismiss(animated: true, completion: nil)
                }))
                
                self.present(passwordAlert, animated: true, completion: nil)
            })
            
            
            
            let touchIDAction = UIAlertAction(title: "Touch ID", style: .default, handler: { (action) in
                if self.isSearching{
                    self.secureNote(id: self.searchingData[indexPAth.row].id!, method: "touchID", password: "", lock: true)
                }else{
                    self.secureNote(id: self.tasks[indexPAth.row].id!, method: "touchID", password: "", lock: true)
                }
            })
            
            
            alert.addAction(dismissAction)
            alert.addAction(touchIDAction)
            alert.addAction(passwordAction)
            
            
            self.present(alert, animated: true, completion: nil)
            
            
            
        }
        
        lock.backgroundColor = UIColor.lightGray
            
            actions.append(lock)
            
        }
        return actions
    }
    
    
    
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        
        let language:String = getLanguage()
        
        
        
        
        let label = UILabel()
        label.font = label.font.withSize(20)
        
        
        switch language {
        case "cz": label.text = "Nemáte žádné poznámky"
        case "en": label.text = "You have no notes"
        default:
            break
        }
        return label
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
    
    
 
   
 
    @IBAction func searchAction(_ sender: Any) {
        if (searchTextfield.text?.isEmpty)!{
            isSearching = false
            searchingData.removeAll()
            TableView.reloadData()
        }else{
            isSearching = true
            findTasks(text: searchTextfield.text!)
        }
    }
    
    
    
    private func findTasks(text:String){
        searchingData.removeAll()
        for i in 0..<tasks.count{
            if tasks[i].title.contains(text){
                searchingData.append(tasks[i])
            }
        }
             TableView.reloadData()
    }
    
    
    

    @IBAction func cancel_touch_down(_ sender: Any) {
        
        let language:String = getLanguage()
        var title:String = ""
        switch language {
        case "cz":title = "Zrušit"
        case "en":title = "Cancel"
        default:
            break
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel_action))
        
    }
    
    @objc func cancel_action(){
        view.endEditing(true)
        self.navigationItem.rightBarButtonItem = nil
    }
    

    private func checkLanguage() -> Bool{
        var available:Bool = false
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Language")
        do{
            let results = try context.fetch(request)
            if results.count > 0{
                available = true
            }else{
                available = false
            }
        }catch{
        }
        return available
    }
    
    
    private func setLanguage() {
       var language:String = ""
        let lang = Locale.preferredLanguages[0]
        if lang == "cs-CZ"{
            language = "cz"
        }else{
            language = "en"
        }
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let data = NSEntityDescription.insertNewObject(forEntityName: "Language", into: context)
        data.setValue(language, forKey: "language")
        
        do{
            try context.save()
        }catch{
            print("Can not save language")
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
    
    
    
    @IBAction func LanguageSwitchAction(_ sender: Any) {
           updateLanguage()
    }
    
        
        
        
    
    
    
    
    
    @objc private func updateLanguage(){
        var target_language:String = ""
        
        let language = getLanguage()
        
        switch language {
        case "en":target_language = "cz"
            self.languageSwitchOutlet.image = #imageLiteral(resourceName: "USA_flag").withRenderingMode(.alwaysOriginal)
            self.navigationItem.title = "Moje poznámky"
            self.addButtonOutlet.setTitle("Přidat poznámku", for: .normal)
            self.searchTextfield.placeholder = "Hledat..."
        case "cz":target_language = "en"
            self.languageSwitchOutlet.image = #imageLiteral(resourceName: "Czechia_flag").withRenderingMode(.alwaysOriginal)
            self.navigationItem.title = "My tasks"
            self.addButtonOutlet.setTitle("Add a note", for: .normal)
            self.searchTextfield.placeholder = "Search..."
        default:
            break
        }
        
        
        
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Language")
        request.includesPropertyValues = false
        do{
            let items = try context.fetch(request)
            
            for item in items{
                context.delete(item as! NSManagedObject)
            }
            try context.save()
        }catch{
            print("Deleting language failed")
        }
        let data = NSEntityDescription.insertNewObject(forEntityName: "Language", into: context)
        data.setValue(target_language, forKey: "language")
        do{
            try context.save()
        }catch{
            print("Can not save new language")
        }
      
        TableView.reloadData()
        
        
    }
    
    
    private func secureNote(id:String, method:String, password:String, lock:Bool){
        
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        do{
            let items = try context.fetch(request)
            
            for s in items as! [NSManagedObject]{
                if s.value(forKey: "id") as! String == id{
                    s.setValue(lock, forKey: "locked")
                    s.setValue(method, forKey: "method")
                    s.setValue(password, forKey: "password")
                }
            }
            try context.save()
        }catch{
            print("Can not lock a note")
        }
        tasks.removeAll()
        self.loadTasks()
        TableView.reloadData()
        
        
    }
    
 
    
  
} // end of class



class customCell:UITableViewCell{
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var colorLabel: UILabel!
    
    
}













