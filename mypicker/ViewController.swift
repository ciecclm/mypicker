//
//  ViewController.swift
//  mypicker
//
//  Created by clm on 2017/7/10.
//  Copyright © 2017年 clm. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    @IBOutlet weak var pPicker: UIPickerView!
    @IBOutlet weak var iPicker: UIPickerView!
    @IBOutlet weak var dPicker: UIPickerView!
    @IBOutlet weak var multiplep: UITextField!
    @IBOutlet weak var multiplei: UITextField!
    @IBOutlet weak var multipled: UITextField!
    
    @IBOutlet weak var ipAdress: UITextField!
    @IBOutlet weak var port: UITextField!
    var client: TCPClient?
    var pMessage="0123"
    var iMessage="0000"
    var dMessage="0000"
    
    @IBAction func ConnectServer(_ sender: Any) {
        client = TCPClient(address: ipAdress.text!, port: Int32(port.text!)!)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    //    client = TCPClient(address: host, port: Int32(port))
        pPicker.dataSource = self
        pPicker.delegate = self
        iPicker.dataSource = self
        iPicker.delegate = self
        dPicker.dataSource = self
        dPicker.delegate = self
        //设置TextField的起始值
        ipAdress.placeholder="192.168.0.129"
        port.placeholder="8899"
        multiplep.placeholder = "1"
        multiplei.placeholder = "1"
        multipled.placeholder = "1"

        
        //设置键盘类型
        ipAdress.keyboardType = .numbersAndPunctuation
        //port.keyboardType = .numbersAndPunctuation
        //设置代理
        ipAdress.delegate=self
        port.delegate=self
        multiplep.delegate=self
        multiplei.delegate=self
        multipled.delegate=self
        //设置TextField的位置
        //mytext.center = CGPoint(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.5);
        //把TextField加入视图View中
        self.view.addSubview(ipAdress);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    //设置选择框的行数为9行，继承于UIPickerViewDataSource协议
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    //设置选择框各选项的内容，继承于UIPickerViewDelegate协议
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        if(pickerView.restorationIdentifier=="P"){
    
            pMessage = String(pickerView.selectedRow(inComponent: 0))+String(pickerView.selectedRow(inComponent: 1))+String(pickerView.selectedRow(inComponent: 2))+String(pickerView.selectedRow(inComponent: 3))
        }
        if(pickerView.restorationIdentifier=="I"){
            
            iMessage = String(pickerView.selectedRow(inComponent: 0))+String(pickerView.selectedRow(inComponent: 1))+String(pickerView.selectedRow(inComponent: 2))+String(pickerView.selectedRow(inComponent: 3))
        }
        if(pickerView.restorationIdentifier=="D"){
            
            dMessage = String(pickerView.selectedRow(inComponent: 0))+String(pickerView.selectedRow(inComponent: 1))+String(pickerView.selectedRow(inComponent: 2))+String(pickerView.selectedRow(inComponent: 3))
        }

        print("p:"+pMessage)
        print("I:"+iMessage)
        print("D:"+dMessage)
        let mp=(multiplep.text as! NSString).intValue
        let mi=(multiplei.text as! NSString).intValue
        let md=(multipled.text as! NSString).intValue
        let tempstr=String(format:"%04d",mp)+String(format:"%04d",mi)+String(format:"%04d",md)
        let senmessage=pMessage+iMessage+dMessage+tempstr
        print("send:"+senmessage)
        
        
        guard let client = client else { return "0"}
        
        switch client.connect(timeout: 10) {
        case .success:
            appendToTextField(string: "Connected to host \(client.address)")
            if let response = sendRequest(string: senmessage, using: client) {
                appendToTextField(string: "Response: \(response)")
            }
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
        

        return String(row)
    }
    
    
    /*override func didReceiveMemoryWarning() {
        
    }*/
    //设置点击键盘返回键隐藏键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.ipAdress.endEditing(true)
        self.port.endEditing(true)
        self.multiplep.endEditing(true)
        self.multiplei.endEditing(true)
        self.multipled.endEditing(true)

        //也可以用下面这个方法
        //self.mytext.resignFirstResponder();
        return true;
    }
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        appendToTextField(string: "Sending data ... ")
        
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            appendToTextField(string: String(describing: error))
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
    
    private func appendToTextField(string: String) {
        print(string)
        ipAdress.text = ipAdress.text?.appending("\n\(string)")
    }



}

