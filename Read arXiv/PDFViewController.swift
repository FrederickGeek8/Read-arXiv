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
    var pdfData: Data?
    
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if pdfurl != nil {
            
                URLSession.shared.dataTask(with: self.pdfurl!) { (data, res, err) in
                    if err != nil {
                        let alert = UIAlertController(title: "Error", message: "There was an error while trying to load the PDF.", preferredStyle: .alert)
                        self.present(alert, animated: true)
                        return
                    }
                    DispatchQueue.main.async {
                        self.pdfData = data
                        let document = PDFDocument(data: data!)
                        self.pdfView.document = document
                        self.loadingIndicator.stopAnimating()
                    }
                }.resume()
                
            
        }
    
        pdfView.autoScales = true
        
        
        let shareBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePDF))
        self.navigationItem.rightBarButtonItem = shareBtn
    }
    
    @objc
    func sharePDF(_ sender: UIBarButtonItem) {
        if pdfData == nil {
            return
        }
        
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [self.pdfData!], applicationActivities: nil)
        

        activityViewController.popoverPresentationController?.barButtonItem = sender
        activityViewController.popoverPresentationController?.permittedArrowDirections = .any
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

        self.present(activityViewController, animated: true, completion: nil)
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
