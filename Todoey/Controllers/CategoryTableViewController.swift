//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by MD Tanvir Alam on 24/3/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {

    var categories = [Category]()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    //MARK:- TableViewDataSourceMethods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    //MARK:- TableViewDelegateMethods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories[indexPath.row]
        }
        
    }
    
    //MARK:- IBActions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add", message: "Add new Category", preferredStyle: .alert)
        var gtextField = UITextField()
        alert.addTextField { (textField) in
            textField.placeholder = "Category name"
            gtextField = textField
        }
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //add data to database
            let newCategory = Category(context: self.context)
            newCategory.name = gtextField.text
            do{
                try self.context.save()
                print("Category saved successfully")
            }catch{
                print("Error saving Data")
            }
            self.loadData()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- OtherFunctions
    func loadData(){
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do{
            categories = try context.fetch(request)
            print("fetching data is successful")
        }catch{
            print("Error fetching Data: \(error)")
        }
        tableView.reloadData()
    }
    
    
}
