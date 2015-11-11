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

enum FilterTypes: Int {
    case Last30Days = 1
    case Last90Days = 3
    case Last180Days = 6
    case Last360Days = 12
    case Last720Days = 24
}

class DashboardViewController: UIViewController, ENSideMenuDelegate, ChartViewDelegate, UITableViewDelegate {

    
    var months: [String]!
    
    
    @IBOutlet weak var openInvoicesValueLabel: UILabel!
    @IBOutlet weak var openInvoicesDetailLabel: UILabel!
    
    @IBOutlet weak var overdueInvoicesValueLabel: UILabel!
    @IBOutlet weak var overdueInvoicesDetailLabel: UILabel!
    
    @IBOutlet weak var paidInvoicesValueLabel: UILabel!
    @IBOutlet weak var paidInvoicesDetailLabel: UILabel!
    
    
    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var expensesPieChart: PieChartView!
    
    @IBOutlet weak var latestIncomeLabel: UILabel!
    
    @IBOutlet weak var netIncomeLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    
    @IBOutlet weak var netIncomeChart: CombinedChartView!
    @IBOutlet weak var netIncomeDayFilter: UISegmentedControl!
    
    
    
    var categorisedExpenseItems : [CategorisedExpenseItemViewModel] = []
    
    var inventoryAPI: InventoryAPI!
    
    var fromDate: NSDate!
    var filterType: FilterTypes = FilterTypes.Last360Days
    
    
    var openInvoicesValue: Double = 0.0 {
        didSet {
            openInvoicesValueLabel.text = "R \(openInvoicesValue)"
        }
    }
    var openInvoicesCount: Int = 0 {
        didSet {
            openInvoicesDetailLabel.text = "\(openInvoicesCount) Open Invoices"
        }
    }
    var overdueInvoicesValue: Double = 0.0 {
        didSet {
            overdueInvoicesValueLabel.text = "R \(overdueInvoicesValue)"
        }
    }
    var overdueInvoicesCount: Int = 0 {
        didSet {
            overdueInvoicesDetailLabel.text = "\(overdueInvoicesCount) Overdue"
        }
    }
    var paidInvoicesValue: Double = 0.0 {
        didSet {
            paidInvoicesValueLabel.text = "R \(paidInvoicesValue)"
        }
    }
    var paidInvoicesCount: Int = 0 {
        didSet {
            paidInvoicesDetailLabel.text = "\(paidInvoicesCount) Paid Last 30 Days"
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sideMenuController()?.sideMenu?.delegate = self
        expensesPieChart.delegate = self
        
        inventoryAPI = InventoryAPI()
        
        let last12MonthDate = NSDate().add(componentsDict: ["month":-12])!//.toLocalTime()
        let invoiceItems = inventoryAPI.getInvoices(fromDate: last12MonthDate)
        updateIncomePanel(invoices: invoiceItems)
        
        let last30DaysDate = NSDate().add(componentsDict: ["month":-1])!//.toLocalTime()
        let expenseItems = inventoryAPI.getExpenseItems(fromDate: last30DaysDate)
        categorisedExpenseItems = getCategoriseExpenseItems(expenseItems)
        
        buidExpensesPieChart(categorisedExpenseItems: categorisedExpenseItems)
        
        //fromDate = "2015/01/01".toDate(formatString: "yyyy/MM/dd")
        
        netIncomeDayFilter.selectedSegmentIndex = 1
        self.netIncomDayFilter_IndexChanged(netIncomeDayFilter)
        
        let invoices = inventoryAPI.getInvoices(fromDate: fromDate)
        let netIncomeExpenseItems = inventoryAPI.getExpenseItems(fromDate: fromDate)
        buildNetIncomeChart(invoices: invoices, expenseItems: netIncomeExpenseItems)
        
        
        //expensesPieChart.highlightValue(xIndex: 0, dataSetIndex: 0, callDelegate: true)
        
        //let startPoint = CGPoint(x: self.view.frame.width - 60, y: 55)
        //let aView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 180))
        //let popover = Popover()
        //popover.show(aView, point: startPoint)
    }
    
    func getCategoriseExpenseItems(expenseItems: [ExpenseItem]) -> [CategorisedExpenseItemViewModel] {
        var categorisedExpenseItems = [CategorisedExpenseItemViewModel]()
        for expenseItem in expenseItems {
            
            if let categorisedExpenseItem = categorisedExpenseItems.filter({ $0.expenseId == expenseItem.expenseId }).first {
                categorisedExpenseItem.totalCost += expenseItem.cost
                categorisedExpenseItem.quantity++
            } else {
                categorisedExpenseItems.append(CategorisedExpenseItemViewModel(
                    expenseId: expenseItem.expenseId,
                    expenseName: expenseItem.expense.name,
                    totalCost: expenseItem.cost,
                    quantity: 1))
            }
        }
    
        return categorisedExpenseItems
    }
    
    func updateIncomePanel(invoices invoices: [Invoice]) {
        
        openInvoicesValue = 0.0
        openInvoicesCount = 0
        overdueInvoicesValue = 0.0
        overdueInvoicesCount = 0
        paidInvoicesValue = 0.0
        paidInvoicesCount = 0
        
        for invoice in invoices {
            if (invoice.invoiceStatus == InvoiceStatus.Paid) {
                let last30Days = NSDate().add(componentsDict: ["month":-1])
                if (invoice.date > last30Days) {
                    paidInvoicesCount++
                    paidInvoicesValue += invoice.getAmountDue()
                }
            } else {
                if (invoice.isOverdue() == true) {
                    overdueInvoicesCount++
                    overdueInvoicesValue += invoice.getAmountDue()
                } else {
                    openInvoicesCount++
                    openInvoicesValue += invoice.getAmountDue()
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorisedExpenseItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: DashExpenseTableViewCell! = tableView.dequeueReusableCellWithIdentifier("dashExpenseCell") as! DashExpenseTableViewCell
        if(cell == nil) {
            cell = NSBundle.mainBundle().loadNibNamed("dashExpenseCell", owner: self, options: nil)[0] as! DashExpenseTableViewCell;
        }
        
        cell.colorView.backgroundColor = categorisedExpenseItems[indexPath.row].color
        cell.priceLabel.text = "R \(categorisedExpenseItems[indexPath.row].totalCost)"
        cell.titleLabel.text = categorisedExpenseItems[indexPath.row].expenseName
        cell.quantityLabel.text = "x\(categorisedExpenseItems[indexPath.row].quantity)"
        
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
        colorView.backgroundColor = categorisedExpenseItems[indexPath.row].color
        cell?.selectedBackgroundView = colorView
    }
    
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let indexPath = NSIndexPath(forRow: highlight.xIndex, inSection: 0)
        expensesTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        self.tableView(expensesTableView, didSelectRowAtIndexPath: indexPath)
    }
    
    func buidExpensesPieChart(categorisedExpenseItems categorisedExpenseItems:  [CategorisedExpenseItemViewModel] ) {
        expensesPieChart.descriptionText = ""
        expensesPieChart.usePercentValuesEnabled = true
        
        var expenses = Double(0)
        var expensesColors: [UIColor] = []
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<categorisedExpenseItems.count {
            let green = Double(RandomInt(min: 100, max: 256))
            let blue = Double(RandomInt(min: 200, max: 256))
            let color = UIColor (red: CGFloat(0), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            categorisedExpenseItems[i].color = color
            expensesColors.append(color)
            
            expenses += categorisedExpenseItems[i].totalCost
            dataEntries.append(ChartDataEntry(value: categorisedExpenseItems[i].totalCost, xIndex: i))
        }
        
        latestIncomeLabel.text = "R \(expenses)"
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: [String](), dataSet: pieChartDataSet)
        //pieChartData.setDrawValues(false)
        expensesPieChart.data = pieChartData
        
        pieChartDataSet.colors = expensesColors
        
        expensesPieChart.notifyDataSetChanged()
        
        expensesPieChart.animate(xAxisDuration: 0.2, yAxisDuration: 0.2)
    }
    
    
    @IBAction func netIncomDayFilter_IndexChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filterType = FilterTypes.Last30Days
            fromDate = NSDate().add(componentsDict: ["month":-1])!.toLocalTime()
        case 1:
            filterType = FilterTypes.Last90Days
            fromDate = NSDate().add(componentsDict: ["month":-3])!.toLocalTime()
        case 2:
            filterType = FilterTypes.Last180Days
            fromDate = NSDate().add(componentsDict: ["month":-6])!.toLocalTime()
        case 3:
            filterType = FilterTypes.Last360Days
            fromDate = NSDate().add(componentsDict: ["month":-12])!.toLocalTime()
        case 4:
            filterType = FilterTypes.Last720Days
            fromDate = NSDate().add(componentsDict: ["month":-24])!.toLocalTime()
            
        default:
            filterType = FilterTypes.Last360Days
            fromDate = NSDate().add(componentsDict: ["month":-12])!.toLocalTime()
            
        }
        
        
        fromDate = NSDate().add(componentsDict: ["month":-filterType.rawValue])!
        
        
        fromDate = "\(fromDate.year)/\(fromDate.month)/01".toDate(formatString: "yyyy/MM/dd")!.toLocalTime()
        
        let invoices = inventoryAPI.getInvoices(fromDate: fromDate)
        let netIncomeExpenseItems = inventoryAPI.getExpenseItems(fromDate: fromDate)
        buildNetIncomeChart(invoices: invoices, expenseItems: netIncomeExpenseItems)
    }
    
    
    func buildNetIncomeChart(invoices invoices: [Invoice], expenseItems: [ExpenseItem]) {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        var dataPoints = [String]()
        var dateUnits = [[Double]]()
        let today = NSDate()
        
        
        switch filterType {
            
        case FilterTypes.Last30Days:
            var i = 0
            for _ in (today.day - 30)...today.day {
                
                let date = today.add(componentsDict: ["day":-(30 - i)])!
                
                
                
                let dataPoint = "\(date.day) \(months[date.month - 1])"
                dataPoints.append(dataPoint)
                
                var invoiceUnit = Double(0)
                let currentInvoices = invoices.filter({ $0.date.year == date.year && $0.date.month == date.month && $0.date.day == date.day})
                for invoice in currentInvoices {
                    for lineItem in invoice.lineItems {
                        invoiceUnit += lineItem.getTotalPrice()
                    }
                }
                
                var expenseUnit = Double(0)
                let currentExpenses = expenseItems.filter({ $0.date.year == date.year && $0.date.month == date.month && $0.date.day == date.day})
                for expense in currentExpenses {
                    expenseUnit += expense.cost
                }
                
                dateUnits.append([invoiceUnit, -expenseUnit])
                i++;
            }
            
        case FilterTypes.Last90Days, FilterTypes.Last180Days, FilterTypes.Last360Days, FilterTypes.Last720Days:
            var i = 0
            for month in (today.month - filterType.rawValue)...today.month {
                
                var monthIndex = month;
                while(monthIndex <= 0) {
                    monthIndex += 12
                }
                
                dataPoints.append(months[monthIndex - 1])
                
                let date = today.add(componentsDict: ["month":-(filterType.rawValue - i)])!
                //date = "\(date.year)/\(date.month)/01".toDate(formatString: "yyyy/MM/dd")!
                var invoiceUnit = Double(0)
                let currentInvoices = invoices.filter({ $0.date.year == date.year && $0.date.month == date.month})
                for invoice in currentInvoices {
                    for lineItem in invoice.lineItems {
                        invoiceUnit += lineItem.getTotalPrice()
                    }
                }
                
                var expenseUnit = Double(0)
                let currentExpenses = expenseItems.filter({ $0.date.year == date.year && $0.date.month == date.month })
                for expense in currentExpenses {
                    expenseUnit += expense.cost
                }
                
                dateUnits.append([invoiceUnit, -expenseUnit])
                i++;
            }
            
        }
        
        
        var netIncome = Double(0)
        var income = Double(0)
        var expenses = Double(0)
        
        var dataEntries: [ChartDataEntry] = []
        var dataEntries1: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            
            let currentIncome = dateUnits[i][0];
            let currentExpenses = dateUnits[i][1]
            let currentNetIncome = currentIncome + currentExpenses
            
            let dataEntry = ChartDataEntry(value: currentNetIncome, xIndex: i)
            dataEntries.append(dataEntry)
            
            let dataEntry1 = BarChartDataEntry(values: dateUnits[i], xIndex: i)
            dataEntries1.append(dataEntry1)
            
            
            netIncome += currentNetIncome
            income += currentIncome
            expenses += currentExpenses
        }
        
        netIncomeLabel.text = "R \(netIncome)"
        incomeLabel.text = "R \(income)"
        expensesLabel.text = "R \(-expenses)"
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Net Income")
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries1, label: "")
        let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        chartDataSet.colors = [UIColor.flatGreenColor(), UIColor.flatSkyBlueColor()]
        
        
        let combinedChartData = CombinedChartData(xVals: dataPoints)
        combinedChartData.lineData = lineChartData
        combinedChartData.barData = chartData
        
        netIncomeChart.data = combinedChartData
        
        netIncomeChart.descriptionText = ""
        netIncomeChart.legend.enabled = false
        
        let prefix = "R "
        let formatter: NSNumberFormatter = NSNumberFormatter()
        formatter.positivePrefix = prefix
        formatter.negativePrefix = prefix
        netIncomeChart.leftAxis.valueFormatter = formatter
        netIncomeChart.rightAxis.valueFormatter = formatter
        
        netIncomeChart.animate(xAxisDuration: 0.2, yAxisDuration: 0.2)
    }

    
    
    @IBAction func toggleSideMenu(sender: UIBarButtonItem) {
        toggleSideMenuView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

