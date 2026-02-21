//
//  Assignment.swift
//  Sylly
//
//

import Foundation
import SwiftData


@Model   // tells phone to save these individual assignments in the database
class Assignment {
    // info about the specific assignment
    var id: UUID
    var title: String
    var dueDate: Date
    var type: String
    var isCompleted: Bool
    var course: Course?  //   '?' means it's optional, this assignment belongs to a course, but it might exist without one temporarily

    // Stores the Apple Calendar event ID after export.
    // nil = not exported yet, String = already in calendar (prevents duplicates)
    var calendarEventID: String?

    init(
        title: String,
        dueDate: Date,
        type: String = "homework",    // if AI can't decide on what type it is, the default will always be as "homework"
        isCompleted: Bool = false     // new assignments start as not finished (false)
    ){
        self.id = UUID()
        self.title = title
        self.dueDate = dueDate
        self.type = type
        self.isCompleted = isCompleted
        self.calendarEventID = nil  // No calendar event yet
    }
}
