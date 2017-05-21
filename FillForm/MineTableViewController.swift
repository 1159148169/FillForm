//
//  MineTableViewController.swift
//  FillForm
//
//  Created by Shi Feng on 2017/4/19.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class MineTableViewController: UITableViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    var currentUser = (UIApplication.shared.delegate as! AppDelegate).currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: #selector(alert), for: .touchUpInside)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 3
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                print("我发布的")
                let alert = UIAlertController(title: "抱歉", message: "您必须先登录才能查看表格", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
                alert.addAction(alertAction)
                present(alert, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                print("我收藏的")
                let alert = UIAlertController(title: "抱歉", message: "您必须先登录才能查看表格", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
                alert.addAction(alertAction)
                present(alert, animated: true, completion: nil)
            }
        } else if indexPath.section == 2 {
            print("关于我们")
            let alert = UIAlertController(title: "抱歉", message: "此页面需要一个UI妹子协助完成", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
        } else {
            print("用户信息")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if currentUser != nil {
            loginButton.isHidden = true
        } else {
            loginButton.isHidden = false
        }
    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "LogIn" {
//            let navigationController = segue.destination as! UINavigationController
//            let logInController = navigationController.topViewController as! LogInViewController
//        }
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func alert() {
        let alert = UIAlertController(title: "抱歉", message: "后台开发人员暂时不允许登陆", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}
