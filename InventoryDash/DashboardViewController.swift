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

class DashboardViewController: UIViewController, ENSideMenuDelegate {

    @IBOutlet weak var barChartView: BarChartView!
    
    var months: [String]!
    
    @IBOutlet weak var expensesPieChart: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.sideMenuController()?.sideMenu?.delegate = self
        
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        setChart(months, values: unitsSold)
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

