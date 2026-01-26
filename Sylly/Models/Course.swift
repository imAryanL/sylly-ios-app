//
//  Course.swift
//  Sylly
//
//

import Foundation
import SwiftData



@Model    // Saved data object
class Course {
    var id: UUID   // A unique ID to tell what course is which
    var name: String
    var code: String
    var icon: String
    var color: String
    var createdAt: Date // exact date and time this course was created
    
    
    // 'Relationship' - connection to other data, the setup process for a new Course
    @Relationship(deleteRule: .cascade)   // 'cascade' means if you delete the Course, all its Assignments are deleted too
    var assignments: [Assignment] = []   // each course has a list of assignments, right now the assignment list is empty
    
    

    init(  // Initializer that uses raw materials like the name of the class, these parameters are the empty boxes someone has to fill out
        name: String,
        code: String,
        icon: String = "book.closed.fill",
        color: String = "BrandPrimary"
    ){
        // This part is where the AI views and writes the information from the user sending their Syllabus form
        self.id = UUID()
        self.name = name
        self.code = code
        self.icon = icon
        self.color = color
        self.createdAt = Date()
    }

}
