//
//  cli.swift
//  ReKatana
//
//  Created by Mauro Bolis on 12/08/16.
//  Copyright © 2016 BendingSpoons. All rights reserved.
//

import Foundation


/// An enum used to list all the implemented operations in the
/// application
enum Operation: Int {
  case createAlbum
  case listAlbums
  case addPhotoCameraRoll
}


func askOperation() -> Operation {
  
  let question = "What do you want to do?" +
    "\n0) Create a new album" +
    "\n1) List albums" +
    "\n2) Add photo from camera roll"

  let error = "Invalid choice"
  
  return aksQuestion(question, error: error, until: {
    let c = Int($0)
    
    if let c = c {
      return Operation(rawValue: c)
    }
    
    return nil
  })
}