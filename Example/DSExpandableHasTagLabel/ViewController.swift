//
//  ViewController.swift
//  DSExpandableHasTagLabel
//
//  Created by dharmilShiyani on 05/04/2024.
//  Copyright (c) 2024 dharmilShiyani. All rights reserved.
//

import UIKit
import DSExpandableHasTagLabel

class ViewController: UIViewController {

    //MARK: - Variable Declaration
    private var arrList = ["Just finished reading a great book on #iOS development by @dev_guru. The insights and tips shared were incredibly valuable, and I can't wait to apply them to my own projects. The chapter on design patterns was particularly enlightening, and I now have a much clearer understanding of how to structure my code for better scalability and maintainability.",
    "#AppReview: Recently tried out a new productivity app by @app_ninja, and I must say, I'm impressed. The app's interface is clean and intuitive, making it easy to organize tasks and stay on top of deadlines. The feature that allows you to create custom tags for tasks is especially useful, as it lets you categorize and prioritize tasks according to your workflow.",
    "#SwiftUI has been a game-changer for iOS development, and I'm loving the flexibility and ease of use it offers. Thanks to @swift_genius for the informative tutorials and code snippets that have helped me grasp the concepts quickly. I'm excited to explore more advanced techniques and create even more polished apps with SwiftUI.",
    "Just attended a virtual meetup hosted by @ios_community, and it was a great experience. The session on advanced debugging techniques was particularly insightful, and I learned a lot of new tricks that will definitely come in handy in my future projects. It's inspiring to see such a vibrant and supportive community of iOS developers.",
    "#CodeSnippet: Here's a handy snippet for creating a custom tab bar in SwiftUI. Thanks to @swift_coder for sharing this! It's a great example of how SwiftUI simplifies complex UI tasks and allows for greater customization."]
    
    //MARK: - Outlet Declaration
    @IBOutlet var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initConfig()
    }


}

//MARK: - Init Config
extension ViewController {
    
    private func initConfig() {
        self.tblView.register(UINib(nibName: "ListTCell", bundle: nil), forCellReuseIdentifier: "ListTCell")
        self.tblView.delegate = self
        self.tblView.dataSource = self
    }
    
}

//MARK: - UITablview Delegate & Datasource Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.arrList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTCell", for: indexPath) as? ListTCell else { return UITableViewCell() }
        
        if self.arrList.indices ~= indexPath.row {
            cell.lblTitle.shouldCollapse = true
            cell.lblTitle.textReplacementType = .word
            cell.lblTitle.numberOfLines = 2
            cell.lblTitle.expandedAttributedLink = NSAttributedString(string: "Read Less", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0, weight: .medium)])
            cell.lblTitle.collapsedAttributedLink = NSAttributedString(string: "Read More", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0, weight: .medium)])

            cell.lblTitle.collapsed = true
            cell.lblTitle.text = self.arrList[indexPath.row]
            cell.lblTitle.onHashtagTapped = { hashTag in
                self.showAlert(with: "\(hashTag) Tapped")
            }
            cell.lblTitle.onTagUserTapped = { mentionUser in
                self.showAlert(with: "\(mentionUser) Tapped")
            }
            cell.lblTitle.delegate = self
        }
        return cell
    }
    
}

//MARK: - ExpandableLabel Delegate Method
extension ViewController: DSExpandableHasTagLabelDelegate {
    
    func willExpandLabel(_ label: DSExpandableHasTagLabel) {
        tblView.beginUpdates()
    }
    
    func didExpandLabel(_ label: DSExpandableHasTagLabel) {
        tblView.endUpdates()
    }
    
    func willCollapseLabel(_ label: DSExpandableHasTagLabel) {
        tblView.beginUpdates()
    }
    
    func didCollapseLabel(_ label: DSExpandableHasTagLabel) {
        tblView.endUpdates()
    }
    
}

extension UIViewController {
    
    
    func showAlert(withTitle title: String = "", with message: String, firstButton: String = "Ok", firstHandler: ((UIAlertAction) -> Void)? = nil, secondButton: String? = nil, secondHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: firstButton, style: .default, handler: firstHandler))
        if secondButton != nil {
            alert.addAction(UIAlertAction(title: secondButton!, style: .default, handler: secondHandler))
        }
        present(alert, animated: true)
    }
}
