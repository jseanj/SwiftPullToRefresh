//
//  ViewController.swift
//  SwiftPullRefreshDemo
//
//  Created by jins on 14/10/29.
//  Copyright (c) 2014年 BlackWater. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var count = 20
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*let refresh = RefreshControl(frame: CGRectMake(0, 0, 320, -50))
        weak var theRefresh = refresh
        refresh.refreshClosure = {
            println("trigger using closure mode")
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                println("end refresh")
                theRefresh?.endRefresh()
            })
        }
        self.tableView.addSubview(refresh)*/
        
        let loadMore = LoadMoreControl(frame: CGRectMake(0, 0, 320, 50))

//        loadMore.backgroundColor = UIColor.yellowColor()
        weak var theloadMore = loadMore
        loadMore.loadingClosure = {
            println("trigger using closure mode")
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                println("end refresh")
                theloadMore?.successLoadMore()
                let count = self.count
                self.count += 10
                self.tableView.beginUpdates()
                var indxesPath:[NSIndexPath] = [NSIndexPath]()
                for i in 0...9 {
                    indxesPath.append(NSIndexPath(forRow: count + i, inSection: 0))
                }
                self.tableView.insertRowsAtIndexPaths(indxesPath, withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.endUpdates()
            })
        }

        self.tableView.tableFooterView = loadMore
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = indexPath.row.description
        return cell
    }

}

