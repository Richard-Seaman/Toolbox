//
//  HomeVC.swift
//  Toolbox
//
//  Created by Richard Seaman on 06/12/2015.
//  Copyright © 2015 RichApps. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var contentView:UIView = UIView()
    
    var actionViews:[ActionView] = [ActionView]()
    
    // Change the spacing between the buttons here
    let spacer:CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
        
        // Get the action views
        self.actionViews = self.getActionViews()
        
        // Layout the action views
        self.layoutViews()
        
        // For testing purposes
        // self.scrollView.backgroundColor = UIColor.redColor()
        // self.contentView.backgroundColor = UIColor.greenColor()
        
        // Prevent blank space appearing at top of scrollview
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getActionViews() -> [ActionView] {
        
        var generatedActionViews:[ActionView] = [ActionView]()
        
        // Duct sizer action view
        let ductSizer:ActionView = ActionView()
        ductSizer.label.text = "Duct\nSizer"
        ductSizer.button.setImage(UIImage(named: "DuctButton"), for: UIControlState())
        ductSizer.button.addTarget(self, action: #selector(HomeVC.ductButtonTapped), for: UIControlEvents.touchUpInside)
        
        generatedActionViews.append(ductSizer)
        
        // Pipe sizer action view
        let pipeSizer:ActionView = ActionView()
        pipeSizer.label.text = "Pipe\nSizer"
        pipeSizer.button.setImage(UIImage(named: "PipeButton"), for: UIControlState())
        pipeSizer.button.addTarget(self, action: #selector(HomeVC.pipeButtonTapped), for: UIControlEvents.touchUpInside)
        
        generatedActionViews.append(pipeSizer)
        
        // Water demand action view
        let waterDemand:ActionView = ActionView()
        waterDemand.label.text = "Water\nDemand"
        waterDemand.button.setImage(UIImage(named: "TapButton"), for: UIControlState())
        waterDemand.button.addTarget(self, action: #selector(HomeVC.waterButtonTapped), for: UIControlEvents.touchUpInside)
        
        generatedActionViews.append(waterDemand)
        
        // Daylight action view
        let daylightCalculator:ActionView = ActionView()
        daylightCalculator.label.text = "Daylight\nCalculator"
        daylightCalculator.button.setImage(UIImage(named: "DaylightButton"), for: UIControlState())
        daylightCalculator.button.addTarget(self, action: #selector(HomeVC.daylightButtonTapped), for: UIControlEvents.touchUpInside)
        
        generatedActionViews.append(daylightCalculator)
        
        /*
        // Dummy action views for testing layout
        let viewsToAdd:Int = 9
        for index in 1...viewsToAdd {
            let dummyActionView:ActionView = ActionView()
            dummyActionView.label.text = "Dummy Action \(index)"
            dummyActionView.button.addTarget(self, action: "testButtonTap", forControlEvents: UIControlEvents.TouchUpInside)
            generatedActionViews.append(dummyActionView)
        }
        */
        
        // Return the array of action views
        return generatedActionViews
        
    }
    
    func layoutViews() {
        
        
        // Figure out how many columns we have
        
        // Get the widths of the screen and an action view
        let screenWidth:CGFloat = self.view.frame.width
        let actionViewWidth:CGFloat = self.actionViews[0].width
        
        // Measure the width when an action view is added and repeat until it doesn't fit on the screen
        // Initial position is the width of the first spacer (for the margin)
        var currentWidth:CGFloat = spacer
        
        var maxNumberOfColumns:Int = 0
        repeat {
            
            // Increment the width by another actionview and spacer
            currentWidth = currentWidth + spacer + actionViewWidth
            
            if (currentWidth <= screenWidth) {
                // Increment the number of columns
                maxNumberOfColumns = maxNumberOfColumns + 1
            }
            
        } while currentWidth < screenWidth
        
        print("Max number of ActionView Columns = \(maxNumberOfColumns)")
        
        
        var actualNumberOfColumns:Int = Int()
        if (maxNumberOfColumns <= self.actionViews.count) {
            actualNumberOfColumns = maxNumberOfColumns
        }
        else {
            actualNumberOfColumns = self.actionViews.count
        }
        
        print("Actual number of ActionView Columns = \(actualNumberOfColumns)")
        
        // Determine the number of rows
        // This is needed to determine the size of the content view which must be added before we layout the action views (which is why we can't do below)
        var columnCount = 0
        var rowCount = 0
        
        // Loop through each of the action views
        for index in 0...self.actionViews.count - 1 {
            
            // Increment the column counter
            columnCount += 1
            
            // Increment the row count if it's the first view
            if (index == 0) {
                rowCount += 1
            }
            
            // If the column reaches the max number of columns, reset it and increment the row counter
            if columnCount > maxNumberOfColumns {
                columnCount = 1
                rowCount += 1
            }
            
        }
        
        print("Actual number of ActionView Rows = \(rowCount)")
        
        // Add the content view to the scroll view
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(self.contentView)
        
        // Add height constraint to the content view so that the scrollview knows how much to allow to scroll
        let contentViewHeight:CGFloat = CGFloat(rowCount) * (self.actionViews[0].height + spacer) + spacer
        let contentViewHeightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: contentViewHeight)
        
        // Add width constraint so that we can center it
        let contentViewWidth:CGFloat = CGFloat(actualNumberOfColumns) * (self.actionViews[0].width + spacer) + spacer
        let contentViewWidthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: contentViewWidth)
        
        print("Content w x h : \(contentViewWidth) x \(contentViewHeight)")
        
        // Add the constraints
        self.contentView.addConstraints([contentViewHeightConstraint, contentViewWidthConstraint])
        
        // Position the content view in the scrollview
        let contentViewTopConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.scrollView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        
        let contentViewBottomConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.scrollView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        
        let contentViewHorizontalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.scrollView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        
        // Add the contentView position constraints to the scrollview
        self.scrollView.addConstraints([contentViewTopConstraint, contentViewBottomConstraint, contentViewHorizontalConstraint])
        
        
        
        var columnCounter:Int = 0
        var rowCounter:Int = 0
        
        // Loop through each of the action views
        for index in 0...self.actionViews.count - 1 {
            
            // Place the card in the view and turn off translateautoresizingmask
            let thisActionView:ActionView = self.actionViews[index]
            thisActionView.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(thisActionView)
            
            // Set the height and width constraints
            let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: thisActionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: thisActionView.height)
            
            let widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: thisActionView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: thisActionView.width)
            
            thisActionView.addConstraints([heightConstraint, widthConstraint])
            
            // Set autolayout constraints within ActionView
            self.applySizeConstraintsToActionView(thisActionView)
            self.applyPositioningConstraintsToActionView(thisActionView)
            
            // Set the horizontal position
            if columnCounter > 0 {
                // View is not in the first column
                let actionViewOnTheLeft:ActionView = self.actionViews[index - 1]
                
                let leftMarginConstraint:NSLayoutConstraint = NSLayoutConstraint(item: thisActionView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: actionViewOnTheLeft, attribute: NSLayoutAttribute.right, multiplier: 1, constant: spacer)
                
                // Add constraint
                self.contentView.addConstraint(leftMarginConstraint)
            }
            else {
                // Card is in the first column
                let leftMarginConstraint:NSLayoutConstraint = NSLayoutConstraint(item: thisActionView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: spacer)
                
                // Add the constraint
                self.contentView.addConstraint(leftMarginConstraint)
            }
            
            // Set the vertical position
            if rowCounter > 0 {
                // Card is not in the first row
                let actionViewOnTop:ActionView = self.actionViews[index - maxNumberOfColumns]
                
                let topMarginConstraint:NSLayoutConstraint = NSLayoutConstraint(item: thisActionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: actionViewOnTop, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: spacer)
                
                // Add constraint
                self.contentView.addConstraint(topMarginConstraint)
            }
            else {
                // Card is in the first row
                let topMarginConstraint:NSLayoutConstraint = NSLayoutConstraint(item: thisActionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: spacer)
                
                // Add constraint
                self.contentView.addConstraint(topMarginConstraint)
            }
            
            // Increment the column counter
            columnCounter += 1
            
            // If the column reaches the max number of columns, reset it and increment the row counter
            if columnCounter >= maxNumberOfColumns {
                columnCounter = 0
                rowCounter += 1
            }
            
        }
        
        
    }
    
    func applySizeConstraintsToActionView(_ actionView:ActionView) {
        
        // Set translates autoresizingmask to false
        actionView.button.translatesAutoresizingMaskIntoConstraints = false
        actionView.label.translatesAutoresizingMaskIntoConstraints = false
        
        // set constraints for the button
        let buttonHeightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: actionView.button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: actionView.width)
        
        let buttonWidthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: actionView.button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: actionView.width)
        
        actionView.button.addConstraints([buttonHeightConstraint, buttonWidthConstraint])
        
        
        // set constraints for the button
        let labelHeightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: actionView.label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: actionView.labelHeight)
        
        let labelWidthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: actionView.label, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: actionView.width)
        
        actionView.label.addConstraints([labelHeightConstraint, labelWidthConstraint])
        
    }
    
    func applyPositioningConstraintsToActionView(_ actionView:ActionView) {
        
        // Set the position of the button to the parent view
        let buttonTopConstraint:NSLayoutConstraint = NSLayoutConstraint(item: actionView.button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: actionView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        
        let buttonLeftConstraint:NSLayoutConstraint = NSLayoutConstraint(item: actionView.button, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: actionView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        
        let buttonRightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: actionView.button, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: actionView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        
        // Set the relative position of the objects
        let buttonBottomConstraint:NSLayoutConstraint = NSLayoutConstraint(item: actionView.button, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: actionView.label, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        
        // Set the position of the label to the parent view
        let labelLeftConstraint:NSLayoutConstraint = NSLayoutConstraint(item: actionView.label, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: actionView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        
        let labelRightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: actionView.label, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: actionView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        
        let labelBottomConstraint:NSLayoutConstraint = NSLayoutConstraint(item: actionView.label, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: actionView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        
        // Add the constraints to the parent view
        actionView.addConstraints([buttonTopConstraint, buttonLeftConstraint, buttonRightConstraint, buttonBottomConstraint, labelLeftConstraint, labelRightConstraint, labelBottomConstraint])
    }
    
    // MARK: - Button functions
    
    func testButtonTap() {
        print("Button Tapped")
    }
    
    func ductButtonTapped() {
        print("ductButtonTapped")
        performSegue(withIdentifier: "toDuct", sender: self)
    }
    func pipeButtonTapped() {
        print("pipeButtonTapped")
        performSegue(withIdentifier: "toPipe", sender: self)
    }
    func waterButtonTapped() {
        print("waterButtonTapped")
        performSegue(withIdentifier: "toWater", sender: self)
    }
    func daylightButtonTapped() {
        print("daylightButtonTapped")
        performSegue(withIdentifier: "toDaylight", sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
