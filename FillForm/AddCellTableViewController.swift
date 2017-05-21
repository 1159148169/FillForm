//
//  AddCellTableViewController.swift
//  FillForm
//
//  Created by Shi Feng on 2017/4/11.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddCellTableViewController: UITableViewController, UITextFieldDelegate {
    
    var form = Form()
    var formItemStringArray = [String]()
    var formText = [String]()
    var textFieldArray: [UITextField] = []
    var formItemString = ""
    var serialKey = ""
    
    let postSucessNotification = Notification.Name(rawValue: "postSuccess")
    let postFailureNotification = Notification.Name(rawValue: "postFailure")

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        for i in 0 ..< form.headArray.count {
            formText.append(textFieldArray[i].text!)
        }
        for i in 0 ..< form.headArray.count {
            formItemStringArray.append(formText[i])
        }
        
        print(formItemStringArray)
        formItemString = formItemStringArray.joined(separator: ",")
        print(formItemString)
        print(serialKey)
        postFormItem(formItemString, serialKey)
        
        NotificationCenter.default.addObserver(forName: self.postSucessNotification, object: nil, queue: OperationQueue.main) { (Notification) in
            self.noticeSuccess("上传成功")
            let delayInSeconds = 0.8
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds, execute: {
                self.clearAllNotice()
                self.dismiss(animated: true, completion: nil)
            })
        }
        NotificationCenter.default.addObserver(forName: self.postFailureNotification, object: nil, queue: OperationQueue.main) { (Notification) in
            self.noticeError("上传失败")
            let delayInSeconds = 0.8
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds, execute: {
                self.clearAllNotice()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serialKey = form.serialKey
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return form.headArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return form.headArray[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath) as! AddCell // 这里的cell可以理解成已经通过indexPath做了一个循环
        
//        if let cell = tableView.cellForRow(at: indexPath) as? AddCell {
//            let textField = cell.textField
//            textFieldArray.append(textField!)
//            setPlaceholder(textFieldArray: textFieldArray)
//        }
        
//        if cell == nil {
//            cell = UITableViewCell(style: .default, reuseIdentifier: "AddCell") as? AddCell
//        }
//        else {
//            //删除cell的所有子视图
//            while cell?.contentView.subviews.last != nil {
//                (cell?.contentView.subviews.last)?.removeFromSuperview()
//            }
//        }
        
        let textField = cell.textField

//        textField = textFieldArray[indexPath.row]
        
        textFieldArray.append(textField!)
        setPlaceholder(textFieldArray: textFieldArray)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setPlaceholder(textFieldArray: [UITextField]) {
        for i in 0 ..< textFieldArray.count {
            textFieldArray[i].placeholder = "(填写示例)" + form.sampleArray[i]
        }
    }
    
    // Post填好的内容
    func postFormItem(_ formItemString: String, _ serialKey: String) {
        let parm: Parameters = [
            "serial_key": serialKey,
            "content": formItemString
        ]
        
/************
         以下为返回的结构，不是标准JSON格式
         SUCCESS: {
            status = 200;
         }
         但是通过JSON.init()方法可以转换为标准JSON格式
 ************/
        
        Alamofire.request("http://120.24.71.96/tinysd/apiv1.0/fill_in_table/", method: .post, parameters: parm, encoding: URLEncoding.default).responseJSON { (response) in
            print(response)
            switch response.result {
            case .success(let data): let json = JSON.init(data)
            print(json)
            if json["status"] == 200 {
                print("上传成功!")
                NotificationCenter.default.post(name: self.postSucessNotification, object: nil)
            } else {
                print("上传失败!")
                NotificationCenter.default.post(name: self.postFailureNotification, object: nil)
                }
            case .failure(let error): print("上传失败,错误: \(error)")
                NotificationCenter.default.post(name: self.postFailureNotification, object: nil)
            }
        }
    }

}
