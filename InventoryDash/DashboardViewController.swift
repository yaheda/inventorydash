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
import SwiftDate

enum FilterTypes {
    case last30Days
    case thisMonth
    case thisQuarter
    case thisYear
    case lastMonth
    case lastQuarter
    case lastYear
}

class DashboardViewController: UIViewController, ENSideMenuDelegate, ChartViewDelegate, UITableViewDelegate {

    @IBOutlet weak var barChartView: BarChartView!
    
    var months: [String]!
    
    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var expensesPieChart: PieChartView!
    @IBOutlet weak var netIncomeChart: CombinedChartView!
    
    var expenseItems: [ExpenseItem]!
    
    var inventoryAPI: InventoryAPI!
    
    var fromDate: NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sideMenuController()?.sideMenu?.delegate = self
        expensesPieChart.delegate = self
        
        inventoryAPI = InventoryAPI()
        
        fromDate = "2015/01/01".toDate(formatString: "yyyy/MM/dd")
        
        let last30DaysDate = NSDate().add(componentsDict: ["month":-1])!.toLocalTime()
        expenseItems = inventoryAPI.getExpenseItems(fromDate: last30DaysDate)
        
        buidExpensesPieChart(expenseItems: expenseItems)
        
        
        let invoices = inventoryAPI.getInvoices(fromDate: fromDate)
        
        
        let netIncomeExpenseItems = inventoryAPI.getExpenseItems(fromDate: fromDate)
        buildNetIncomeChart(invoices: invoices, expenseItems: netIncomeExpenseItems)
        
        
        //expensesPieChart.highlightValue(xIndex: 0, dataSetIndex: 0, callDelegate: true)
        
        //let startPoint = CGPoint(x: self.view.frame.width - 60, y: 55)
        //let aView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 180))
        //let popover = Popover()
        //popover.show(aView, point: startPoint)
    }
    
    func getCategoriseExpenseItems(expenseItems: [ExpenseItem]) -> [Int:[ExpenseItem]] {
        var categorisedExpenseItems = [Int:[ExpenseItem]]()
        for expenseItem in expenseItems {
            if let _ = categorisedExpenseItems[expenseItem.expense.id] as [ExpenseItem]! {
                categorisedExpenseItems[expenseItem.expense.id]?.append(expenseItem)
            } else {
                categorisedExpenseItems[expenseItem.expense.id] = [ExpenseItem]()
                categorisedExpenseItems[expenseItem.expense.id]?.append(expenseItem)
            }
        }
        return categorisedExpenseItems
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: DashExpenseTableViewCell! = tableView.dequeueReusableCellWithIdentifier("dashExpenseCell") as! DashExpenseTableViewCell
        if(cell == nil) {
            cell = NSBundle.mainBundle().loadNibNamed("dashExpenseCell", owner: self, options: nil)[0] as! DashExpenseTableViewCell;
        }
        
        cell.colorView.backgroundColor = expenseItems[indexPath.row].color
        cell.priceLabel.text = "R " + expenseItems[indexPath.row].cost.description
        cell.titleLabel.text = expenseItems[indexPath.row].expense.name
        
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
        colorView.backgroundColor = expenseItems[indexPath.row].color
        cell?.selectedBackgroundView = colorView
    }
    
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let indexPath = NSIndexPath(forRow: highlight.xIndex, inSection: 0)
        expensesTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        self.tableView(expensesTableView, didSelectRowAtIndexPath: indexPath)
    }
    
    func buidExpensesPieChart(expenseItems expenseItems: [ExpenseItem]) {
        expensesPieChart.descriptionText = ""
        expensesPieChart.usePercentValuesEnabled = true
        
        
        
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<expenseItems.count {
            let dataEntry = ChartDataEntry(value: expenseItems[i].cost, xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: [String](), dataSet: pieChartDataSet)
        //pieChartData.setDrawValues(false)
        expensesPieChart.data = pieChartData
        
        var expensesColors: [UIColor] = []
        for i in 0..<expenseItems.count {
            //let red = Double(arc4random_uniform(256))
            let green = Double(RandomInt(min: 100, max: 256))
            let blue = Double(RandomInt(min: 200, max: 256))
            
            let color = UIColor (red: CGFloat(0), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            expenseItems[i].color = color
            expensesColors.append(color)
        }
        
        pieChartDataSet.colors = expensesColors
        
        expensesPieChart.notifyDataSetChanged()
        //expensesPieChart.legend.position = ChartLegend.ChartLegendPosition.LeftOfChart
    }
    
    
    func buildNetIncomeChart(invoices invoices: [Invoice], expenseItems: [ExpenseItem]) {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        let filterType = FilterTypes.thisYear
        
        var dataPoints = [String]()
        var dateUnits = [[Double]]()
        
        if filterType == FilterTypes.thisYear {
            let lastInvoice = invoices.last!
            let lastExpenseItem = expenseItems.last!
            
            var lastMonth = lastInvoice.date.month
            if lastExpenseItem.date.month > lastMonth {
                lastMonth = lastExpenseItem.date.month
            }
            
            //var invoiceIndex = 0
            //var expenseIndex = 0
            
            for month in 1...lastMonth {
                dataPoints.append(months[month - 1])
                
                var invoiceUnit = Double(0)
                let currentInvoices = invoices.filter({ $0.date.month == month})
                for invoice in currentInvoices {
                    for lineItem in invoice.lineItems {
                        invoiceUnit += lineItem.getTotalPrice()
                    }
                }
                
                /*for invoiceIndex; invoiceIndex < invoices.count; invoiceIndex++ {
                    if invoices[invoiceIndex].date.month == month {
                        for lineItem in invoices[invoiceIndex].lineItems {
                            invoiceUnit += lineItem.getTotalPrice()
                        }
                    }
                }*/
                
                var expenseUnit = Double(0)
                let currentExpenses = expenseItems.filter({ $0.date.month == month })
                for expense in currentExpenses {
                    expenseUnit += expense.cost
                }
                
                /*for expenseIndex; expenseIndex < expenses.count; expenseIndex++ {
                    if expenses[expenseIndex].date.month == month {
                        expenseUnit += expenses[expenseIndex].cost
                    }
                }*/
                
                dateUnits.append([invoiceUnit, -expenseUnit])
            }
        }
        
        
        
        //let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        //let unitsSold1 = [[60.0,-20], [40,-60], [60,-30], [30,-10], [35,-12], [16,-20]]
        
        var dataEntries: [ChartDataEntry] = []
        var dataEntries1: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let netIncome = dateUnits[i][0] + dateUnits[i][1]
            let dataEntry = ChartDataEntry(value: netIncome, xIndex: i)
            dataEntries.append(dataEntry)
            
            let dataEntry1 = BarChartDataEntry(values: dateUnits[i], xIndex: i)
            dataEntries1.append(dataEntry1)
        }
        
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries1, label: "Units Sold1")
        let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        chartDataSet.colors = [UIColor.flatGreenColor(), UIColor.flatSkyBlueColor()]
        
        let combinedChartData = CombinedChartData(xVals: dataPoints)
        combinedChartData.lineData = lineChartData
        combinedChartData.barData = chartData
        
        netIncomeChart.data = combinedChartData
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

