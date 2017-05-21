//
//  SearchFormViewController.swift
//  FillForm
//
//  Created by Shi Feng on 2017/4/10.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class SearchFormViewController: UIViewController {
    
    var dataTask: URLSessionDataTask?
    var searchResult: [String: Any]?
    var form = Form()
    var isLoading = false
    var hasLoaded = false
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
    }
    
    @IBAction func addForm(_ sender: Any) {
        let alert = UIAlertController(title: "抱歉", message: "您必须先登录才能发布表格", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.searchBar.placeholder = "输入表格的唯一关键字来搜索"
        self.searchResultTableView.emptyDataSetSource = self
        self.searchResultTableView.emptyDataSetDelegate = self
        self.searchResultTableView.tableFooterView = UIView()
        
        //以下代码自定义了一个手势用来隐藏键盘
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false //不取消点击处的其它action
        searchResultTableView.addGestureRecognizer(tapGestureRecognizer)
        
        searchResultTableView.rowHeight = 150
        
        // 新建一个UINib对象，并且在tableView注册该对象
        let cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        searchResultTableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parse(json data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON ERROR: \(error)")
            return nil
        }
    }
    
    //隐藏键盘
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
}

extension SearchFormViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SearchToAdd", sender: indexPath)
        searchResultTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchToAdd" {
            let navigationController = segue.destination as! UINavigationController
            let addCellController = navigationController.topViewController as! AddCellTableViewController
            addCellController.form = form
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let collect = UITableViewRowAction(style: .default, title: "收藏") { (UITableViewRowAction, indexPath) in
            // 点击收藏后的操作
            let alert = UIAlertController(title: "抱歉", message: "您必须先登录才能收藏表格", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        }
        collect.backgroundColor = UIColor.lightGray
        return [collect]
    }
    
}

extension SearchFormViewController: UITableViewDataSource {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasLoaded {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { 
        let cell = self.searchResultTableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell) as! SearchResultCell
        cell.formName.text = form.name
        return cell
    }
}

extension SearchFormViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchFormViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.pleaseWait()
        performSearch()
        print(searchBar.text as Any)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        hasLoaded = false
        self.searchResultTableView.reloadData()
    }
    
    func performSearch() {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            dataTask?.cancel()
            
            searchResultTableView.reloadData()
            
            let url = URL(string: "http://120.24.71.96/tinysd/apiv1.0/get_table_info/" + searchBar.text!)!
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    print("表格示例API返回错误: \(error)")
                    return
                }
                
                self.searchResult = self.parse(json: data!)
                self.form.name = self.searchResult!["name"] as! String
                self.form.head = (self.searchResult!["head"] as! String).replacingOccurrences(of: "\r", with: "")
                self.form.headArray = (self.form.head as NSString).components(separatedBy: ",")
                self.form.sample = self.searchResult!["sample"] as! String
                self.form.sampleArray = (self.form.sample as NSString).components(separatedBy: ",")
                self.form.serialKey = self.searchResult!["serial_key"] as! String
                print(self.form.head)
                print(self.form.headArray)
                print(self.form.sample)
                print(self.form.sampleArray)
                print(self.form.name)
                print(self.form.serialKey)
                print("搜索结果: \(String(describing: self.searchResult))")
                
                DispatchQueue.main.async {
                    self.clearAllNotice()
                    self.hasLoaded = true
                    self.noticeSuccess("已找到")
                    self.searchResultTableView.reloadData()
                    let delayInSeconds = 1.2
                    DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds, execute: {
                        self.clearAllNotice()
                    })
                }
                return
            })
            
            DispatchQueue.main.async {
                self.hasLoaded = false
                self.searchResultTableView.reloadData()
            }
            
            dataTask?.resume()
        }
    }
}

extension SearchFormViewController: DZNEmptyDataSetDelegate,DZNEmptyDataSetSource {
    //DZNEmptyDataSet协议中方法的实现
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "FillForm.png")
    }
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = "极为简洁，极为高效的填写表单"
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(18.0)), NSForegroundColorAttributeName: UIColor.darkGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = "在搜索框中搜索表单ID查询对应表单\n点击查询结果填写表单\n左滑收藏该表单\n点击 + 即可发布属于你自己的表单"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(14.0)), NSForegroundColorAttributeName: UIColor.lightGray, NSParagraphStyleAttributeName: paragraph]
        return NSAttributedString(string: text, attributes: attributes)
        
    }
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(17.0))]
        return NSAttributedString(string: "It's easy!", attributes: attributes)
        
    }
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        //print("成功调用!")
        return UIColor.white
    }
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation? {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Double.pi/2), 0.0, 0.0, 1.0))
        animation.duration = 0.25
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        //print("成功调用!")
        return animation
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView) -> Bool {
        return false
    }
}
