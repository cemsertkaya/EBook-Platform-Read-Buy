//
//  PdfReaderController.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 28.01.2021.
//

import UIKit
import PDFKit


class PdfReaderController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var viewMain: PDFView!
    @IBOutlet weak var leftPageNumber: UITextView!
    @IBOutlet weak var rightPageNumber: UITextView!
    var isLocked = false //if user presses stop button, pdf is locked on the page
    var document = PDFDocument()
    var currentFileUrl = String()
    var startingPageNumber = Int64()
    var libraryMapInPdf = [String:Int64]()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        leftPageNumber.delegate = self
        leftPageNumber.keyboardType = .numberPad
        if currentFileUrl != ""
        {
            let libraryPath = FirebaseUtil.getPdfFromLibrary(id: currentFileUrl)
            let url = URL(string: libraryPath)
            if url != nil{document = PDFDocument(url:url!)!}
        }
        viewMain.document = document
        viewMain.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
        viewMain.displayDirection = .vertical
        viewMain.autoScales = true
        viewMain.displayMode = .singlePageContinuous
        viewMain.usePageViewController(true)
        viewMain.displaysPageBreaks = true
        viewMain.maxScaleFactor = 4.0
        viewMain.minScaleFactor = viewMain.scaleFactorForSizeToFit
        viewMain.backgroundColor = UIColor.white
        rightPageNumber.text =  "/" + String(document.pageCount)
        let validStartingPageIndex: Int = Int(startingPageNumber)
        let page = viewMain.document?.page(at:validStartingPageIndex)
        if page != nil{viewMain.go(to: page!)}
        let index = document.index(for: viewMain.currentPage!)
        leftPageNumber.text = String(index+1)
        NotificationCenter.default.addObserver(self,selector: #selector(pageDidChange(notification:)),name: Notification.Name.PDFViewPageChanged,object: nil)
    }
    
    
    ///is called from notification center when user skip the page, updates current page label
    @objc private func pageDidChange(notification: Notification)
    {
          // pdfView is of type PDFView
        let index = document.index(for: viewMain.currentPage!)
        leftPageNumber.text = String(index+1)
     }

    
    ///stop button action, updates ebooks map in firestore
    @IBAction func stopButtonAction(_ sender: Any)
    {
        let index = document.index(for: viewMain.currentPage!)
        let validPageIndex: Int = index // current page
        if libraryMapInPdf[currentFileUrl] != nil
        {
            libraryMapInPdf[currentFileUrl]  = Int64(validPageIndex) //updates dict
            FirebaseUtil.updateEbooksDict(dict: libraryMapInPdf, userId: CoreDataUtil.getCurrentUser().getUserId())
        }
        else{print("Current pdf id does not exist in map.")}
    }
    
   ///Next page button action
    @IBAction func nextPageAction(_ sender: Any)//next page button
    {
        let index = document.index(for: viewMain.currentPage!)
        let validPageIndex: Int = index + 1
        guard let targetPage = viewMain.document!.page(at: validPageIndex) else { return }
        print(targetPage.index)
        viewMain.go(to: targetPage)
    }
    
    ///Previous button action
    @IBAction func previousPageAction(_ sender: Any)//previous page button
    {
        let index = document.index(for: viewMain.currentPage!)
        let validPageIndex: Int = index - 1
        guard let targetPage = viewMain.document!.page(at: validPageIndex) else { return }
        print(targetPage.index)
        viewMain.go(to: targetPage)

    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == leftPageNumber && textView.text != ""
        {
            let validPageIndex = Int(textView.text!)
            guard let targetPage = viewMain.document!.page(at: validPageIndex ?? document.pageCount) else {return}
            viewMain.go(to: targetPage)
        }
    }
    
    ///Starts Editing The Text Field
    @objc func didTapView(gesture: UITapGestureRecognizer){view.endEditing(true)}
    
    
}
