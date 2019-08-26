//
//  SubmitController.swift
//  TO-DO-List
//
//  Created by Ivan on 02/07/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import UIKit
import CoreData

class SubmitViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var titleText: UITextField!
    var submiting: Bool?
    var index: Int?
    @IBOutlet weak var button: UIButton!
    var appDelegate: AppDelegate?
    var context: NSManagedObjectContext?
    var listViewController: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = appDelegate?.persistentContainer.viewContext
        if submiting ?? false {
            button.setTitle("Submit", for: .normal)
            descriptionText.text = "Type text here"
        } else {
            button.setTitle("Edit", for: .normal)
            descriptionText.text = listViewController?.toDoList[index!].descriptionText
            titleText.text = listViewController?.toDoList[index!].titleText
        }
        descriptionText.delegate = self
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        if descriptionText.text == "" || descriptionText.text == "Type text here" {
            showToast(message: "You must enter some text")
        } else {
            navigationController?.popViewController(animated: true)
            if submiting ?? false {
                let entity = NSEntityDescription.entity(forEntityName: "Tasked", in: context!)
                let newTask = NSManagedObject(entity: entity!, insertInto: context)
                newTask.setValue(titleText.text, forKey: "titleText")
                newTask.setValue(descriptionText.text, forKey: "descriptionText")
                do {
                    try context?.save()
                } catch {
                    print("Failed saving")
                }
                let task = Task(title: titleText.text!, description: descriptionText.text!)
                listViewController?.toDoList.append(task)
            } else {
                updateData(taskToUpdate: listViewController?.toDoList[index ?? 0] ?? Task(title: "", description: ""))
                listViewController?.toDoList.remove(at: index ?? 0)
                let task = Task(title: titleText.text!, description: descriptionText.text!)
                listViewController?.toDoList.insert(task, at: index ?? 0)
            }
        }
    }
    
    func updateData(taskToUpdate: Task) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasked")
        fetchRequest.predicate = NSPredicate(format: "descriptionText = %@", taskToUpdate.descriptionText)
        do {
            let test = try context?.fetch(fetchRequest)
            let objectToUpdate = test![0] as! NSManagedObject
            objectToUpdate.setValue(descriptionText.text!, forKey: "descriptionText")
            objectToUpdate.setValue(titleText.text!, forKey: "titleText")
            do {
                try context?.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if submiting ?? false {
            descriptionText.text = ""
        }
    }
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-100, width: 250, height: 35))
        toastLabel.numberOfLines = 0
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "", size: 19)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()})
    }
}
