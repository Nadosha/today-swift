//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Andrey on 15.07.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoriesList = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    //MARK: - TableView Datasource and methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoriesList[indexPath.row].name
        
        return cell
    }
    
    //MARK: - TableView delegate methods
      override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          performSegue(withIdentifier: "goToItems", sender: self)
        }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = self.categoriesList[indexPath.row]
        }
    }

    
    
    //MARK: - Data manipulation methods
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Category havn't been saved, according error: \(error)||")
        }
        self.tableView.reloadData()
    }
    func loadData(with request: NSFetchRequest<Category> = Category.fetchRequest())  {
        do {
            categoriesList = try context.fetch(request)
        } catch {
            print("Categories cannot be loaded according error: \(error)")
        }
    }
    
    //MARK: - Add new categories
    @IBAction func AddCategoryButtonPressed(_ sender: UIBarButtonItem) {
        var textInput = UITextField()
        let alert = UIAlertController.init(title: "Add new category", message: "Its some kind of folder for your tasks", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add new", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textInput.text!
            self.categoriesList.append(newCategory)
            self.saveData()
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name of your category"
            textInput = textField
        }
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}
