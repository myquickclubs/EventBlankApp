//
//  Database.swift
//  EventBlank
//
//  Created by Marin Todorov on 3/12/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

class RealmProvider {

    static private var eventRealmConfig: Realm.Configuration?
    static private var appRealmConfig: Realm.Configuration?

    static var eventRealm: Realm {
        return try! Realm(configuration: eventRealmConfig!)
    }

    static var appRealm: Realm {
        return try! Realm(configuration: appRealmConfig!)
    }
    
    init(eventFile: String = eventDataFileName, appFile: String = appDataFileName) {
        //event configuration
        if let eventConfig = loadConfig(eventFile, path: FilePath(inLibrary: eventFile), defaultPath: FilePath(inBundle: eventFile), preferNewerSourceFile: true),
            let appConfig = loadConfig(appFile, path: FilePath(inLibrary: appFile), defaultPath: FilePath(inBundle: appFile))
        {
            RealmProvider.eventRealmConfig = eventConfig
            RealmProvider.appRealmConfig = appConfig
        } else {
            fatalError("Can't load the default realm")
        }
    }
    
    func loadConfig(name: String, path targetPath: FilePath, defaultPath: FilePath? = nil, preferNewerSourceFile: Bool = false) -> Realm.Configuration? {
        
        if let defaultPath = defaultPath {
            
            //copy if does not exist in target location
            do {
                try defaultPath.copyOnceTo(targetPath)

                //copy if the bundle contains a newer version
                if preferNewerSourceFile {
                    try defaultPath.copyIfNewer(targetPath)
                }
            } catch let error as NSError {
                fatalError(error.description)
            }
        }
        
        let config = Realm.Configuration(path: targetPath.filePath, readOnly: false)
        loadDatabaseFile(name)
        return config
        
    }
    
    private func loadDatabaseFile(name: String) {
        //TODO: connect a database?
        stubbyProvider(name)
    }
    
    func didChangeSourceFile(name: String, success: Bool) {
        print("Database Provider: reload database: \(name)")
        loadDatabaseFile(name)
    }
    
    func stubbyProvider(name: String) {
        
        // Open the Realm with the configuration
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
            
            let event = Event()
            
            event.title = "Marin Conf '16"
            event.subtitle = "My own conference"
            event.beginDate = NSDate(timeIntervalSinceNow: 0)
            event.endDate = NSDate(timeIntervalSinceNow: 3 * 24 * 60 * 60)
            event.organizer = "Marin Todorov"
            event.mainColor = "#ff3333"
            
            realm.add(event)
        }
    }
}