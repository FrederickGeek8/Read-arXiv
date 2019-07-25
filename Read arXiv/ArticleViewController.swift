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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if article_2 != nil {
            bookmarked = true
            self.articleTitle.text = article_2?.title
            
            let html = "<html><head><meta name='viewport' content='initial-scale=1.0'/><style>p{white-space:initial !important;}</style></head><body><p class='mathjax'>\(article_2!.description)</p><script type='text/x-mathjax-config'>MathJax.Hub.Config({messageStyle: 'none',extensions: ['tex2jax.js'],jax: ['input/TeX','output/HTML-CSS'],tex2jax: {  inlineMath: [['$','$']],  processEscapes: true,  ignoreClass: '.*',  processClass: 'mathjax.*',},TeX: {  extensions: ['AMSmath.js', 'AMSsymbols.js', 'noErrors.js'],  noErrors: {    inlineDelimiters: ['$','$'],    multiLine: true }}       }); </script><script src='MathJax/MathJax.js'></script></body></html>"
            
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
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bookmarkBtn!)
            
            return
        }
        
        let html = "<html><head><meta name='viewport' content='initial-scale=1.0'/><style>p{white-space:initial !important;}</style></head><body><p class='mathjax'>\(article?.summary?.value ?? "")</p><script type='text/x-mathjax-config'>MathJax.Hub.Config({messageStyle: 'none',extensions: ['tex2jax.js'],jax: ['input/TeX','output/HTML-CSS'],tex2jax: {  inlineMath: [['$','$']],  processEscapes: true,  ignoreClass: '.*',  processClass: 'mathjax.*',},TeX: {  extensions: ['AMSmath.js', 'AMSsymbols.js', 'noErrors.js'],  noErrors: {    inlineDelimiters: ['$','$'],    multiLine: true }}       }); </script><script src='MathJax/MathJax.js'></script></body></html>"
        
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bookmarkBtn!)
    }
    
    func updateBookmarkIcon() {
        if bookmarked {
            bookmarkBtn!.setBackgroundImage(UIImage(named: "Bookmark"), for: .normal)
        } else {
            bookmarkBtn!.setBackgroundImage(UIImage(named: "Bookmark Border"), for: .normal)
        }
    }
    
    @objc
    func bookmarkArticle() {
        if pdf == nil {
            return
        }
        
        let documentURL = (pdf?.lastPathComponent)!
        
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: path)
        let pathComponent = url.appendingPathComponent(documentURL + ".json")
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        
        if bookmarked {
            // delete bookmark
            let pdfFileURL = url.appendingPathComponent(documentURL + ".pdf")
            do {
                print(filePath)
                try fileManager.removeItem(atPath: filePath)
                try fileManager.removeItem(atPath: pdfFileURL.path)
            } catch _ {
                print("Failed to remove bookmark.")
            }
            pdfFile = nil
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "documentsChanged")))
        } else {
            // download bookmark
            let data = [
                "title": article?.title,
                "authors": articleAuthors.text,
                "description": article?.summary?.value,
                "id": documentURL
            ]
            
            do {
                let json = try JSONSerialization.data(withJSONObject: data, options: .init())
                fileManager.createFile(atPath: filePath, contents: json, attributes: nil)
            } catch _ {
                print("There was an error saving article metadata.")
                return
            }
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "documentsChanged")))
            
            DownloadDelegate.init(identifier: documentURL, url: pdf!).start()
        }
        
        bookmarked = !bookmarked
        updateBookmarkIcon()
    }
    
    func bookmarkExists() -> Bool {
        if pdf == nil {
            return false
        }
        
        let documentURL = (pdf?.lastPathComponent)!
        
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: path)
        let pathComponent = url.appendingPathComponent(documentURL + ".json")
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            return true
        }
        
        return false
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
