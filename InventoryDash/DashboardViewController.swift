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

    @IBOutlet weak var barChartView: BarChartView!
    
    var months: [String]!
    
    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var expensesPieChart: PieChartView!
    @IBOutlet weak var netIncomeChart: CombinedChartView!
    
    
    
    @IBOutlet weak var netIncomeDayFilter: UISegmentedControl!
    //var expenseItems: [ExpenseItem]!
    //var categorisedExpenseItems: [Int:[ExpenseItem]]!
    var categorisedExpenseItems : [CategorisedExpenseItemViewModel] = []
    
    var inventoryAPI: InventoryAPI!
    
    var fromDate: NSDate!
    var filterType: FilterTypes = FilterTypes.Last360Days
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sideMenuController()?.sideMenu?.delegate = self
        expensesPieChart.delegate = self
        
        
        
        inventoryAPI = InventoryAPI()
        
        
        
        let last30DaysDate = NSDate().add(componentsDict: ["month":-1])!.toLocalTime()
        let expenseItems = inventoryAPI.getExpenseItems(fromDate: last30DaysDate)
        categorisedExpenseItems = getCategoriseExpenseItems(expenseItems)
        
        buidExpensesPieChart(categorisedExpenseItems: categorisedExpenseItems)
        
        fromDate = "2015/01/01".toDate(formatString: "yyyy/MM/dd")
        
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
        
        var expensesColors: [UIColor] = []
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<categorisedExpenseItems.count {
            let green = Double(RandomInt(min: 100, max: 256))
            let blue = Double(RandomInt(min: 200, max: 256))
            let color = UIColor (red: CGFloat(0), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            categorisedExpenseItems[i].color = color
            expensesColors.append(color)
            
            dataEntries.append(ChartDataEntry(value: categorisedExpenseItems[i].totalCost, xIndex: i)
)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: [String](), dataSet: pieChartDataSet)
        //pieChartData.setDrawValues(false)
        expensesPieChart.data = pieChartData
        
        pieChartDataSet.colors = expensesColors
        
        expensesPieChart.notifyDataSetChanged()
        //expensesPieChart.legend.position = ChartLegend.ChartLegendPosition.LeftOfChart
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
        
        let invoices = inventoryAPI.getInvoices(fromDate: fromDate)
        let netIncomeExpenseItems = inventoryAPI.getExpenseItems(fromDate: fromDate)
        buildNetIncomeChart(invoices: invoices, expenseItems: netIncomeExpenseItems)
    }
    
    
    func buildNetIncomeChart(invoices invoices: [Invoice], expenseItems: [ExpenseItem]) {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        
        
        var dataPoints = [String]()
        var dateUnits = [[Double]]()
        
        
        
        
        switch filterType {
            
        case FilterTypes.Last30Days:
            
            break
            
        case FilterTypes.Last90Days, FilterTypes.Last180Days, FilterTypes.Last360Days, FilterTypes.Last720Days:
            let lastInvoice = invoices.last!
            let lastExpenseItem = expenseItems.last!
            
            var lastMonth = lastInvoice.date.month
            if lastExpenseItem.date.month > lastMonth {
                lastMonth = lastExpenseItem.date.month
            }
            
            
            let today = NSDate().toLocalTime()
            let minInvoice = invoices.first
            let minExpenseItem = expenseItems.first
            var minDate = minInvoice?.date
            if minExpenseItem?.date < minDate {
                minDate = minExpenseItem?.date
            }
            
            //for year in (minDate?.year)!...today.year {
            var i = 0
            for month in (today.month - filterType.rawValue)...today.month {
                
                var monthIndex = month;
                while(monthIndex <= 0) {
                    monthIndex += 12
                }
                
                dataPoints.append(months[monthIndex - 1])
                
                var date = today.add(componentsDict: ["month":-(filterType.rawValue - i)])!.toLocalTime()
                //date = "\(date.year)/\(date.month)/01".toDate(formatString: "yyyy/MM/dd")!
                var invoiceUnit = Double(0)
                let currentInvoices = invoices.filter({ $0.date.year == date.year && $0.date.month == date.month})
                for invoice in currentInvoices {
                    for lineItem in invoice.lineItems {
                        invoiceUnit += lineItem.getTotalPrice()
                    }
                }
                
                var expenseUnit = Double(0)
                let currentExpenses = expenseItems.filter({ $0.date.year == date.year && $0.date.month == month })
                for expense in currentExpenses {
                    expenseUnit += expense.cost
                }
                
                dateUnits.append([invoiceUnit, -expenseUnit])
                i++;
            }
            //}
            /*
            for month in 1...lastMonth {
                dataPoints.append(months[month - 1])
                
                var invoiceUnit = Double(0)
                let currentInvoices = invoices.filter({ $0.date.month == month})
                for invoice in currentInvoices {
                    for lineItem in invoice.lineItems {
                        invoiceUnit += lineItem.getTotalPrice()
                    }
                }
                
                var expenseUnit = Double(0)
                let currentExpenses = expenseItems.filter({ $0.date.month == month })
                for expense in currentExpenses {
                    expenseUnit += expense.cost
                }
                
                dateUnits.append([invoiceUnit, -expenseUnit])
            }*/
            
        }
        
        
        
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

