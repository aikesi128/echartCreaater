//
//  AppDelegate.swift
//  test_mac
//
//  Created by zhujunwu on 2021/3/3.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
 
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // 设置应用程序不支持dark模式
        NSApplication.shared.appearance = NSAppearance(named: .aqua)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
 


}

