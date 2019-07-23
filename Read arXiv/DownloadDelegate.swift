//
//  DownloadDelegate.swift
//  arXiv Reader
//
//  Created by Frederick Morlock on 7/21/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import UIKit

class DownloadDelegate: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    var urlSession: URLSession?
    var url: URL
    var identifier: String
    var backgroundTask: URLSessionDownloadTask?
    init(identifier: String, url: URL) {
        print(url)
        
        self.url = url
        self.identifier = identifier
        let config = URLSessionConfiguration.background(withIdentifier: identifier)
        config.sessionSendsLaunchEvents = true
        config.isDiscretionary = false
        
        super.init()
        
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    func start() {
        backgroundTask = urlSession!.downloadTask(with: url)
        
        backgroundTask!.resume()
        print("Beginning download")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let err = error {
            print("Error: \(err.localizedDescription)")
        } else {
            print("Error. Giving up")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let url = URL(fileURLWithPath: path)
            let savedURL = url.appendingPathComponent(identifier + ".pdf")
            try FileManager.default.moveItem(at: location, to: savedURL)
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "documentsChanged")))
            print("File downloaded and moved successfully.")
        } catch _ {
            print("Failed to move file to documents")
        }
    }
}
