//
//  LeftMenuViewController.swift
//  AKSideMenuSimple
//
//  Created by Diogo Autilio on 6/7/16.
//  Copyright © 2016 AnyKey Entertainment. All rights reserved.
//

import UIKit

public class LeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView?
    var storyboardMain, storyboardWords, storyboardPhrases: UIStoryboard!

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let tableView = UITableView(frame: CGRect(x: 0, y: (self.view.frame.size.height - 54 * 10) / 2.0, width: self.view.frame.size.width, height: 54 * 10), style: .plain)
        tableView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isOpaque = false
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil
        tableView.separatorStyle = .none
        tableView.bounces = false

        self.tableView = tableView
        self.view.addSubview(self.tableView!)
        
        storyboardMain = UIStoryboard(name: "Main", bundle: nil)
        storyboardWords = UIStoryboard(name: "Words", bundle: nil)
        storyboardPhrases = UIStoryboard(name: "Phrases", bundle: nil)
    }

    // MARK: - <UITableViewDelegate>

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            self.sideMenuViewController!.setContentViewController(UINavigationController(rootViewController: storyboardMain.instantiateViewController(withIdentifier: "WordsSearchViewController")), animated: true)
            self.sideMenuViewController!.hideMenuViewController()
        case 1:
            self.sideMenuViewController!.setContentViewController(UINavigationController(rootViewController: storyboardMain.instantiateViewController(withIdentifier: "SettingsViewController")), animated: true)
            self.sideMenuViewController!.hideMenuViewController()
        case 2:
            self.sideMenuViewController!.setContentViewController(UINavigationController(rootViewController: storyboardWords.instantiateViewController(withIdentifier: "WordsUnitViewController")), animated: true)
            self.sideMenuViewController!.hideMenuViewController()
        case 3:
            self.sideMenuViewController!.setContentViewController(UINavigationController(rootViewController: storyboardPhrases.instantiateViewController(withIdentifier: "PhrasesUnitViewController")), animated: true)
            self.sideMenuViewController!.hideMenuViewController()
        case 4:
            self.sideMenuViewController!.setContentViewController(UINavigationController(rootViewController: storyboardWords.instantiateViewController(withIdentifier: "WordsReviewViewController")), animated: true)
            self.sideMenuViewController!.hideMenuViewController()
        case 5:
            self.sideMenuViewController!.setContentViewController(UINavigationController(rootViewController: storyboardPhrases.instantiateViewController(withIdentifier: "PhrasesReviewViewController")), animated: true)
            self.sideMenuViewController!.hideMenuViewController()
        case 6:
            self.sideMenuViewController!.setContentViewController(UINavigationController(rootViewController: storyboardWords.instantiateViewController(withIdentifier: "WordsLangViewController")), animated: true)
            self.sideMenuViewController!.hideMenuViewController()
        case 7:
            self.sideMenuViewController!.setContentViewController(UINavigationController(rootViewController: storyboardPhrases.instantiateViewController(withIdentifier: "PhrasesLangViewController")), animated: true)
            self.sideMenuViewController!.hideMenuViewController()
        case 8:
            self.sideMenuViewController!.setContentViewController(UINavigationController(rootViewController: storyboardWords.instantiateViewController(withIdentifier: "WordsTextbookViewController")), animated: true)
            self.sideMenuViewController!.hideMenuViewController()
        case 9:
            self.sideMenuViewController!.setContentViewController(UINavigationController(rootViewController: storyboardPhrases.instantiateViewController(withIdentifier: "PhrasesTextbookViewController")), animated: true)
            self.sideMenuViewController!.hideMenuViewController()
        default:
            break
        }
    }

    // MARK: - <UITableViewDataSource>

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        return 10
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "Cell"

        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            cell!.backgroundColor = .clear
            cell!.textLabel?.font = UIFont(name: "HelveticaNeue", size: 21)
            cell!.textLabel?.textColor = .white
            cell!.textLabel?.highlightedTextColor = .lightGray
            cell!.selectedBackgroundView = UIView()
        }

        var titles = ["Search", "Settings", "Words in Unit", "Phrases in Unit", "Words Review", "Phrases Review", "Words in Language", "Phrases in Language", "Words in Textbook", "Phrases in Textbook"]
        var images = ["IconEmpty", "IconEmpty", "IconEmpty", "IconEmpty", "IconEmpty", "IconEmpty", "IconEmpty", "IconEmpty", "IconEmpty", "IconEmpty"]
        cell!.textLabel?.text = titles[indexPath.row]
        cell!.imageView?.image = UIImage(named: images[indexPath.row])

        return cell!
    }
}
