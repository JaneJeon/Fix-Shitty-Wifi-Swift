//
//  main.swift
//  fix-shitty-wifi
//
//  Created by Jane Jeon on 6/9/18.
//  Copyright © 2018 Jane Jeon. All rights reserved.
//

import Foundation
import CoreWLAN

func env(_ param: String, `default`: String) -> String {
    return ProcessInfo.processInfo.environment[param] ?? `default`
}

// all time intervals are measured in seconds
let minInterval: Float! = Float(env("MIN_INTERVAL", default: "10"))
let maxInterval: Float! = Float(env("MAX_INTERVAL", default: "60"))
let growthRate: Int! = Int(env("GROWTH_RATE", default: "2"))
let maxTries: Int! = Int(env("MAX_TRIES", default: "3"))
let testSite = env("TEST_SITE", default: "www.google.com")
let timeout: Int! = Int(env("TIMEOUT", default: "3"))

let actualMin = minInterval / maxInterval

var failed = 0
var errorInterval = actualMin
var okInterval = actualMin

// print date in current timezone
let dateFormatter = DateFormatter()
dateFormatter.dateStyle = .medium
dateFormatter.timeStyle = .medium

func now() -> String {
    // update timezone every time, since the user could move across timezones
    NSTimeZone.resetSystemTimeZone()
    dateFormatter.timeZone = NSTimeZone.system
    
    return dateFormatter.string(from: Date())
}

// turn wifi on/off
func wifi(_ power: Bool) {
    try! CWWiFiClient.shared().interface()?.setPower(power)
}

// execute one or more shell commands, piped together
func shell(_ commands: [[String]]) -> String {
    var pipe: Pipe?
    var process: Process?
    
    for command in commands {
        process = Process()
        process?.launchPath = command.first
        process?.arguments = Array(command.dropFirst())
        
        process?.standardInput = pipe
        pipe = Pipe()
        process?.standardOutput = pipe
        
        process?.launch()
    }
    
    process?.waitUntilExit()
    
    let data = pipe?.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data!, encoding: .utf8)
    
    return output!
}

// dirty, dirty hax
func lidClosed() -> Bool {
    return shell([["/usr/sbin/ioreg", "-r", "-k", "AppleClamshellState", "-d", "4"],
                  ["/usr/bin/grep", "AppleClamshellState"],
                  ["/usr/bin/awk", "{print $4}"]]) == "Yes"
}
