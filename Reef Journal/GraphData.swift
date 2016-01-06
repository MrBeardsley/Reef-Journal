//
//  GraphData.swift
//  Reef Journal
//
//  Created by Christopher Harding on 1/5/16
//  Copyright © 2016 Epic Kiwi Interactive
//

import Foundation
import CoreData

class GraphData: NSObject {
    
    var weekMeasurements = [Double?]()
    var monthMeasurements = [Double?]()
    var yearMeasurements = [Double?]()
    var currentParameter: Parameter?
    
    
    func fetchMeasurementData() {
        guard let param = currentParameter else { return }
        
        let allMeasurements = measurementsForParameter(param)
        let today = NSDate().dayFromDate()
        let calendar = NSCalendar.currentCalendar()
        let dateComponets = NSDateComponents()
        
        var weekly = [Double?]()
        var monthly = [Double?]()
        var allYear = [Double?]()
        
        for day in -27 ... 0 {
            let index = allMeasurements.indexOf {
                dateComponets.day = day
                guard let startDate = calendar.dateByAddingComponents(dateComponets, toDate: today, options: .MatchStrictly) else { return false }
                return $0.day.compare(startDate) == .OrderedSame
            }
            
            if let i = index {
                switch day {
                case -6...0:
                    weekly.append(allMeasurements[i].convertedValue)
                    monthly.append(allMeasurements[i].convertedValue)
                    break
                case -27...0:
                    monthly.append(allMeasurements[i].convertedValue)
                    break
                default:
                    break
                }
            }
            else {
                switch day {
                case -6...0:
                    weekly.append(nil)
                    monthly.append(nil)
                    break
                case -27...0:
                    monthly.append(nil)
                    break
                default:
                    break
                }
            }
        }
        
        // Need to get an average for all of the previous 10 months
        let getMonth = { (date: NSDate, number: Int) -> Int in
            if let newDate = calendar.dateByAddingUnit(.Month, value: number, toDate: date, options: .MatchStrictly) {
                let components = calendar.components([.Month], fromDate: newDate)
                return components.month
            }
            return 0
        }
        
        for i in -9 ... 0 {
            let month = getMonth(today, i)
            
            let temp = allMeasurements.filter({
                let measurementMonth = calendar.component([.Month], fromDate: $0.day)
                if measurementMonth == month {
                    return true
                }
                return false
            })
            
            if !temp.isEmpty {
                let values = temp.map({ $0.convertedValue })
                let average = values.reduce(0.0) { $0 + $1 / Double(values.count) }
                allYear.append(average)
            }
            else {
                allYear.append(nil)
            }
        }
        
        weekMeasurements = weekly
        monthMeasurements = monthly
        yearMeasurements = allYear
    }
    
    private func measurementsForParameter(param: Parameter) -> [Measurement] {
        
        let fetchRequest = NSFetchRequest(entityName: Measurement.entityName)
        let predicate = NSPredicate(format: "parameter == %@", argumentArray: [param.rawValue])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = Measurement.defaultSortDescriptors
        
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
            if let results = results as? [Measurement] {
                return results
            }
            else { return [] }
        }
        catch {
            let nserror = error as NSError
            NSLog("Error in fetch of measurement for paramter type \(param.rawValue): \(nserror), \(nserror.userInfo)")
            return []
        }
    }
}

// MARK: - Data Model Conformance

extension GraphData: DataModel { }
