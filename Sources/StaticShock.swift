//
//  StaticShock.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

import Foundation
import ArgumentParser
import MarkyMark

@main
struct StaticShock: ParsableCommand {
    @Argument var folder: String
    
    func run() throws {
        var g = Generator(folder: folder)
        try g.create()
    }
}
