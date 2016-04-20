//
//  WidgetETATableViewCellPresenter.swift
//  findmybusnj
//
//  Created by David Aghassi on 4/19/16.
//  Copyright © 2016 David Aghassi. All rights reserved.
//

import UIKit

// Dependencies
import SwiftyJSON
import findmybusnj_common

class WidgetETATableViewCellPresenter: ETAPresenter {
  var sanitizer = JSONSanitizer()
  
  func formatCellForPresentation(cell: UITableViewCell, json: JSON) {
    assignArrivalTimeForJson(cell, json: json)
    assignBusAndRouteTextForJson(cell, json: json)
  }
  
  func assignArrivalTimeForJson(cell: UITableViewCell, json: JSON) {
    guard let currentCell = cell as? WidgetETATableViewCell else {
      return
    }
    
    let arrivalString = sanitizer.getSanatizedArrivalTimeAsString(json)
    let arrivalTime = sanitizer.getSanitizedArrivaleTimeAsInt(json)
    
    if arrivalTime != -1 {
      if arrivalTime ==  NumericArrivals.ARRIVED.rawValue {
        currentCell.timeLabel.text = "Arrive"
        currentCell.timeLabel.textColor = UIColor.whiteColor()
        // render color for view here
      }
      else {
        currentCell.timeLabel.text = arrivalTime.description + " min."
        // render color for view here
        
      }
    }
    else {
      #if DEBUG
        print(arrivalString)
        print(json)
      #endif
      
      switch arrivalString {
      case NonNumericaArrivals.APPROACHING.rawValue:
        currentCell.timeLabel.text = "Arrive"
        currentCell.timeLabel.textColor = UIColor.whiteColor()
      case NonNumericaArrivals.DELAYED.rawValue:
        currentCell.timeLabel.text = "Delay"
        currentCell.timeLabel.textColor = UIColor.whiteColor()
      default:
        currentCell.timeLabel.text = "0"
        currentCell.timeLabel.textColor = UIColor.blueColor()
      }
    }
  }
  
  func assignBusAndRouteTextForJson(cell: UITableViewCell, json: JSON) {
    guard let currentCell = cell as? WidgetETATableViewCell else {
      return
    }
    
    currentCell.routeLabel.text = sanitizer.getSanitizedRouteNumber(json)
    currentCell.routeDescriptionLabel.text = sanitizer.getSanitizedRouteDescription(json)
    currentCell.routeDescriptionLabel.adjustsFontSizeToFitWidth = true
  }
}
