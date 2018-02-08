//
//  CategoriesViewController.swift
//  FindIt
//
//  Created by Mona Ramesh on 4/17/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class CategoriesViewController: UITableViewController{
    
    var categoryStore = CategoryStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        tableView.rowHeight = 65
        
    }
    
    // getting number of rows for table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryStore.categoriesList.count
    }
    
    // number of sections in table
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // populating table cell with image and categories
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath)
        let imageName = UIImage(named: categoryStore.categoriesList[indexPath.row])
        cell.imageView?.image = imageName
        let cat = categoryStore.categoriesList[indexPath.row]
        cell.textLabel?.text = cat
        return cell
    }
    
    // preparing segue with necessary information to be passed to next view controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Segue invoked.")
        
        if segue.identifier == "ShowPlaces" {
            if let row = tableView.indexPathForSelectedRow?.row {
                let cat = categoryStore.categoriesList[row]
                let video = categoryStore.catVideo[row]
                
                let destinationController = segue.destinationViewController as! ViewController
                destinationController.category = cat
                destinationController.catRow = row
                destinationController.catVideo = video
            }
        }
    }
    
    
}

