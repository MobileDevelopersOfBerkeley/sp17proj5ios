//
//  MoonViewController.swift
//  
//
//  Created by Zach Govani on 3/10/17.
//
//

import UIKit
import Foundation

class MoonViewController: UIViewController {
    
    var moon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMoon()
        // Do any additional setup after loading the view.
    }
    
    func setupMoon() {
        moon = UIImageView(frame: CGRect(x: 10, y: 10, width: view.frame.width - 20, height: view.frame.width - 20))
        moon.image = #imageLiteral(resourceName: "moon6")
        view.addSubview(moon)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
