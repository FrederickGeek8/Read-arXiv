//
//  ArticleViewController.swift
//  arXiv Reader
//
//  Created by Frederick Morlock on 7/19/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import UIKit
import FeedKit
import WebKit
import CoreData

class ArticleViewController: UIViewController {
    var article: AtomFeedEntry?
    var article_2: Article?
    var pdf: URL?
    var pdfFile: URL?
    var access: Bool = false
    var bookmarked: Bool = false
    var bookmarkBtn: UIButton?
    
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleAuthors: UILabel!
    @IBOutlet weak var articleDescription: WKWebView!
    @IBOutlet weak var descriptionLoading: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleDescription.navigationDelegate = self
        
        if article_2 != nil {
            bookmarked = true
            self.articleTitle.text = article_2?.title
            
            let html = "<html><head><meta name='viewport' content='initial-scale=1.0'/><style>p{white-space:initial !important;} @media (prefers-color-scheme: dark){body{background:black;color:white;}}</style></head><body><p class='mathjax'>\(article_2!.description)</p><script type='text/x-mathjax-config'>MathJax.Hub.Config({messageStyle: 'none',extensions: ['tex2jax.js'],jax: ['input/TeX','output/HTML-CSS'],tex2jax: {  inlineMath: [['$','$']],  processEscapes: true,  ignoreClass: '.*',  processClass: 'mathjax.*',},TeX: {  extensions: ['AMSmath.js', 'AMSsymbols.js', 'noErrors.js'],  noErrors: {    inlineDelimiters: ['$','$'],    multiLine: true }}       }); </script><script src='MathJax/MathJax.js'></script></body></html>"
            
            articleDescription.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
            
//            self.articleDescription.text = article_2?.description
            self.articleAuthors.text = article_2?.authors
            self.pdf = URL(string: "https://arxiv.org/pdf/\(article_2!.id)")
            
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let url = URL(fileURLWithPath: path)
            
            if access {
                self.pdfFile = url.appendingPathComponent(article_2!.id + ".pdf")
            }
            
            bookmarkBtn = UIButton(type: .custom)
            bookmarkBtn?.addTarget(self, action: #selector(bookmarkArticle), for: .touchUpInside)
            updateBookmarkIcon()
            
            let shareBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareArticle))
            
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: bookmarkBtn!), shareBtn]
            
            NotificationCenter.default.addObserver(self, selector: #selector(recheckBookmark), name: .init(rawValue: "documentsChanged"), object: nil)
            
            return
        }
        
        let html = "<html><head><meta name='viewport' content='initial-scale=1.0'/><style>p{white-space:initial !important;}@media (prefers-color-scheme: dark){body{background:black;color:white;}}</style></head><body><p class='mathjax'>\(article?.summary?.value ?? "")</p><script type='text/x-mathjax-config'>MathJax.Hub.Config({messageStyle: 'none',extensions: ['tex2jax.js'],jax: ['input/TeX','output/HTML-CSS'],tex2jax: {  inlineMath: [['$','$']],  processEscapes: true,  ignoreClass: '.*',  processClass: 'mathjax.*',},TeX: {  extensions: ['AMSmath.js', 'AMSsymbols.js', 'noErrors.js'],  noErrors: {    inlineDelimiters: ['$','$'],    multiLine: true }}       }); </script><script src='MathJax/MathJax.js'></script></body></html>"
        
        articleDescription.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
        self.articleTitle.text = article?.title
//        self.articleDescription.text = article?.summary?.value
        
        var authors = ""
        let raw_authors = article?.authors ?? []
        for author in raw_authors {
            authors += (author.name ?? "") + " "
        }
        
        self.articleAuthors.text = authors
        
        if article?.links == nil {
            return
        }
        
        for link in article!.links! {
            if link.attributes?.title == "pdf" {
                if let href = link.attributes?.href {
                    pdf = URL(string: href)
                }
                break
            }
        }
        
        bookmarked = bookmarkExists()
        
        // Do any additional setup after loading the view.
        bookmarkBtn = UIButton(type: .custom)
        bookmarkBtn?.addTarget(self, action: #selector(bookmarkArticle), for: .touchUpInside)
        updateBookmarkIcon()
        
        let shareBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareArticle))
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: bookmarkBtn!), shareBtn]
        
        NotificationCenter.default.addObserver(self, selector: #selector(recheckBookmark), name: .init(rawValue: "documentsChanged"), object: nil)
    }
    
    func updateBookmarkIcon() {
        if bookmarked {
            bookmarkBtn!.setImage(UIImage(named: "Bookmark")?.maskWithColor(color: self.view.tintColor), for: .normal)
        } else {
            bookmarkBtn!.setImage(UIImage(named: "Bookmark Border")?.maskWithColor(color: self.view.tintColor), for: .normal)
        }
    }
    
    @objc
    func shareArticle(_ sender: UIBarButtonItem) {
        let url: URL?
        if article_2 != nil {
            url = URL(string: "https://arxiv.org/abs/" + self.article_2!.id)
        } else {
            url = URL(string: article!.id!)
        }
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [url as Any], applicationActivities: nil)
        

        activityViewController.popoverPresentationController?.barButtonItem = sender        
        activityViewController.popoverPresentationController?.permittedArrowDirections = .any
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc
    func bookmarkArticle() {
        if pdf == nil {
            return
        }
        
        let documentURL = (pdf?.lastPathComponent)!
        
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: path)
        let fileManager = FileManager.default
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if bookmarked {
            // delete bookmark
            self.bookmarked = false
            updateBookmarkIcon()
            let pdfFileURL = url.appendingPathComponent(documentURL + ".pdf")
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bookmarks")
            fetchRequest.predicate = NSPredicate(format: "articleID==%@", documentURL)
            
            do {
                if let result = try? managedContext.fetch(fetchRequest) {
                    for object in result {
                        managedContext.delete(object)
                    }
                }
                try managedContext.save()
                try fileManager.removeItem(atPath: pdfFileURL.path)
            } catch _ {
                print("Failed to remove bookmark.")
            }
            
            pdfFile = nil
            
            SyncKitManager.shared.sync { (error) in
                if error != nil {
                    print("Error: \(error!)")
                }
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "documentsChanged")))
            }
        } else {
            // download bookmark
            self.bookmarked = false
            updateBookmarkIcon()
            let entity = NSEntityDescription.entity(forEntityName: "Bookmarks", in: managedContext)!
            
            let record = NSManagedObject(entity: entity, insertInto: managedContext)
            
            record.setValue(article?.title, forKey: "articleTitle")
            record.setValue(articleAuthors.text, forKey: "articleAuthors")
            record.setValue(article?.summary?.value, forKey: "articleDescription")
            record.setValue(documentURL, forKey: "articleID")
            
            do {
                try managedContext.save()
            } catch let error {
                print("Error: \(error)")
            }
            
            SyncKitManager.shared.sync { (error) in
                if error != nil {
                    print("Error: \(error!)")
                }
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "documentsChanged")))
            }
            DownloadDelegate.init(identifier: documentURL, url: self.pdf!).start()
        }
    }
    
    func bookmarkExists() -> Bool {
        if pdf == nil {
            return false
        }
        
        let documentURL = (pdf?.lastPathComponent)!
        
        var records: [NSManagedObject] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bookmarks")
        fetchRequest.predicate = NSPredicate(format: "articleID==%@", documentURL)
        
        do {
            records = try managedContext.fetch(fetchRequest)
        } catch let error {
            print("Error: \(error)")
        }
        
        return records.count > 0
    }
    
    @objc func recheckBookmark() {
        DispatchQueue.main.async {
            self.bookmarked = self.bookmarkExists()
            self.updateBookmarkIcon()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "openPDF" && pdf != nil {
            let dest = segue.destination as! PDFViewController
            if pdfFile != nil {
                dest.pdfurl = pdfFile
            } else {
                dest.pdfurl = pdf
            }
            
            
        }
    }
    

}

extension ArticleViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished loading")
        descriptionLoading.stopAnimating()
    }
}
