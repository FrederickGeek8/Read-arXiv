//
//  PDFViewController.swift
//  arXiv Reader
//
//  Created by Frederick Morlock on 7/19/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
    var pdfurl: URL?
    
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if pdfurl != nil {
            DispatchQueue.main.async {
                let document = PDFDocument(url: self.pdfurl!)
                self.pdfView.document = document
                self.loadingIndicator.stopAnimating()
            }
        }
        pdfView.autoScales = true
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
