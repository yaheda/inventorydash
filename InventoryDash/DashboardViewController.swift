//
//  ViewController.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/10/18.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit
import Charts
import Foundation
import Popover

class DashboardViewController: UIViewController, ENSideMenuDelegate, ChartViewDelegate, UITableViewDelegate {

    @IBOutlet weak var barChartView: BarChartView!
    
    var months: [String]!
    
    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var expensesPieChart: PieChartView!
    
    
    var expenses: [Expense]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.sideMenuController()?.sideMenu?.delegate = self
        expensesPieChart.delegate = self
        
        
        expenses = [Expense]()
        expenses.append(Expense(name: "Maintenance and Repairs", value: 7550, color: UIColor.flatBlueColor()))
        expenses.append(Expense(name: "Cost of Goods Sold", value: 4050, color: UIColor.flatBlueColor()))
        expenses.append(Expense(name: "Legal and Professional Services", value: 3900, color: UIColor.flatBlueColor()))
        expenses.append(Expense(name: "Job Expenses", value: 2160, color: UIColor.flatBlueColor()))
        expenses.append(Expense(name: "Everything else", value: 4190, color: UIColor.flatBlueColor()))
            
        
        buidExpensesPieChart(expenses: expenses)
        
        
        
        //expensesPieChart.highlightValue(xIndex: 0, dataSetIndex: 0, callDelegate: true)
        
        //let startPoint = CGPoint(x: self.view.frame.width - 60, y: 55)
        //let aView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 180))
        //let popover = Popover()
        //popover.show(aView, point: startPoint)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: DashExpenseTableViewCell! = tableView.dequeueReusableCellWithIdentifier("dashExpenseCell") as! DashExpenseTableViewCell
        if(cell == nil) {
            cell = NSBundle.mainBundle().loadNibNamed("dashExpenseCell", owner: self, options: nil)[0] as! DashExpenseTableViewCell;
        }
        
        cell.colorView.backgroundColor = expenses[indexPath.row].color
        cell.priceLabel.text = "R " + expenses[indexPath.row].value.description
        cell.titleLabel.text = expenses[indexPath.row].name
        
        return cell as DashExpenseTableViewCell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clearColor()
        
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        expensesPieChart.highlightValues(nil)
        let highlight = ChartHighlight(xIndex: indexPath.row, dataSetIndex: 0)
        expensesPieChart.highlightValue(highlight: highlight, callDelegate: false)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let colorView = UIView()
        colorView.backgroundColor = expenses[indexPath.row].color
        cell?.selectedBackgroundView = colorView
    }
    
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let indexPath = NSIndexPath(forRow: highlight.xIndex, inSection: 0)
        expensesTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        self.tableView(expensesTableView, didSelectRowAtIndexPath: indexPath)
    }
    
    func buidExpensesPieChart(expenses expenses: [Expense]) {
        expensesPieChart.descriptionText = ""
        expensesPieChart.usePercentValuesEnabled = true
        var dataEntries: [ChartDataEntry] = []
        var xx: [String] = []
        for i in 0..<expenses.count {
            let dataEntry = ChartDataEntry(value: expenses[i].value, xIndex: i)
            dataEntries.append(dataEntry)
            xx.append(expenses[i].name)
        }
        
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: [String](), dataSet: pieChartDataSet)
        //pieChartData.setDrawValues(false)
        expensesPieChart.data = pieChartData
        
        var expensesColors: [UIColor] = []
        for i in 0..<expenses.count {
            //let red = Double(arc4random_uniform(256))
            let green = Double(RandomInt(min: 100, max: 256))
            let blue = Double(RandomInt(min: 200, max: 256))
            
            let color = UIColor (red: CGFloat(0), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            expenses[i].color = color
            expensesColors.append(color)
        }
        
        pieChartDataSet.colors = expensesColors
        
        expensesPieChart.notifyDataSetChanged()
        //expensesPieChart.legend.position = ChartLegend.ChartLegendPosition.LeftOfChart
    }

    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        barChartView.descriptionText = ""
        
        let formatter: NSNumberFormatter = NSNumberFormatter()
        formatter.positivePrefix = "R "
        
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.valueFormatter = formatter
        
        //barChartView.legend.setValue(12, forKey: "TextSize")
        barChartView.legend.font = barChartView.legend.font.fontWithSize(15)
        
        var dataEntries: [BarChartDataEntry] = []
        let dataEntry = BarChartDataEntry(values: [52820, 15260], xIndex: 0)
        dataEntries.append(dataEntry)
        
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "")
        chartDataSet.stackLabels = ["Open Invoices", "Overdue"]
        
        chartDataSet.colors = [UIColor.flatYellowColor(), UIColor.flatRedColor()]
        
        
        
        let chartData = BarChartData(xVals: [""], dataSet: chartDataSet)
        chartData.setValueFormatter(formatter)
        chartData.setValueFont(barChartView.legend.font)
        
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        barChartView.data = chartData
    }
    
    
    @IBAction func toggleSideMenu(sender: UIBarButtonItem) {
        toggleSideMenuView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

