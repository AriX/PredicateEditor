//
//  Section.swift
//  Pods
//
//  Created by Arvindh Sukumar on 07/07/16.
//
//

import Foundation

public enum SectionPredicateType {
    case AND
    case OR
}

public class Section {
    public var title: String
    public var keyPathDescriptors: [KeyPathDescriptor] = []
    public var rows: [Row] = []
    public var compoundPredicateType: SectionPredicateType = .AND
    var keyPathTitles: [String] {
        return keyPathDescriptors.map({ (descriptor:KeyPathDescriptor) -> String in
            return descriptor.title
        })
    }
    
    public init(title: String, keyPaths: [KeyPathDescriptor]){
        self.title = title
        self.keyPathDescriptors = keyPaths
    }
    
    public func predicates() throws -> [NSPredicate] {
        let predicates = try rows.flatMap { (row:Row) -> NSPredicate? in
            do {
                return try row.toPredicate()
            }
        }
        return predicates
    }
    
    internal func ANDPredicate() throws -> NSCompoundPredicate {
        return try NSCompoundPredicate(andPredicateWithSubpredicates: predicates())
    }
    
    internal func ORPredicate() throws -> NSCompoundPredicate {
        return try NSCompoundPredicate(orPredicateWithSubpredicates: predicates())
    }
    
    public func compoundPredicate() throws -> NSCompoundPredicate {
        return try compoundPredicateType == .OR ? ORPredicate() : ANDPredicate()
    }
}

extension Section {
    public func append(row: Row) {
        // TODO: Check if row's descriptor is included in section?
        rows.append(row)
        row.section = self
    }
    
    public func insertRow(row: Row, atIndex: Int){
        rows.insert(row, atIndex: atIndex)
    }
    
    public func deleteRow(row: Row){
        for (i,r) in rows.enumerate() {
            if row === r {
                rows.removeAtIndex(i)
            }
        }
    }
}

extension Section {
    func descriptorWithTitle(title: String) -> KeyPathDescriptor? {
        return keyPathDescriptors.filter({ (descriptor:KeyPathDescriptor) -> Bool in
            return descriptor.title == title
        }).first
    }
}