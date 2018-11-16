//
//  CloudKitHelper.swift
//  FotoFoto
//
//  Created by Daniel Gunawan on 16/11/18.
//  Copyright © 2018 Daniel Gunawan. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

typealias onFetchRecordSuccess = ([Story]) -> Void

class CloudKitHelper {
    
    func createStoryRecord(story: Story) {
        let record = CKRecord(recordType: "Story")
        
        record["title"] = story.title
        record["location"] = CLLocation(latitude: story.coordinate.latitude, longitude: story.coordinate.longitude)
        
        saveRecord(record: record)
    }
    
    func saveRecord(record: CKRecord) {
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        
        database.save(record) { (record, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Success Insert")
            }
        }
    }
    
    func fetchStoryRecord(onFetchSuccess: @escaping onFetchRecordSuccess) {
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        
        //        let record = CKRecord(recordType: "Story")
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Story", predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error Fetch: \(error.localizedDescription)")
            } else {
                print("Success Fetch")
                var stories = [Story]()
                records?.forEach({ (record) in
                    if let story = self.convertRecordToStory(record: record) {
                        stories.append(story)
                    }
                })
                
                onFetchSuccess(stories)
            }
        }
    }
    
    func convertRecordToStory(record: CKRecord) -> Story? {
        print(record)
        guard let title = record["title"] as? String,
            let location = record["location"] as? CLLocation,
            let thumbnail = record["image"] as? CKAsset else {
                return nil
        }
        
        do {
            let imageData = try Data(contentsOf: thumbnail.fileURL)
            let image = UIImage(data: imageData)
            
            let story = Story(title: title, coordinate: location.coordinate, thumbnail: image!)
            return story
        } catch  {
            print("Error: \(error.localizedDescription)")
        }
        
        return nil
    }
}

// hapus belakangan
struct Story {
    let title: String
    let coordinate: CLLocationCoordinate2D
    let thumbnail: UIImage
}
