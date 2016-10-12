//
//  ViewController.swift
//  GPSTest
//
//  Created by 山本隼也 on 2016/10/11.
//  Copyright © 2016年 山本隼也. All rights reserved.
//

import UIKit
import CoreLocation

// CLLocationManagerDelegateを継承しなければならない
class ViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate{
    
    // 現在地の位置情報の取得にはCLLocationManagerを使用
    var locationManager: CLLocationManager!
    // 取得した緯度を保持するインスタンス
    var latitude: CLLocationDegrees!
    // 取得した経度を保持するインスタンス
    var longitude: CLLocationDegrees!
    //行き先の緯度
    var destinationLatitude: Double = 35.66201
    //行き先の経度
    var destinationLongitude: Double = 139.366313
    //行き先の位置情報
    var destinations = ["日野キャン", "南大沢キャン", "荒川キャン", "新宿サテライト"]
    var destination: CLLocation!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // フィールドの初期化
        locationManager = CLLocationManager()
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
        
        // CLLocationManagerをDelegateに指定
        locationManager.delegate = self
        
        // 位置情報取得の許可を求めるメッセージの表示．必須．
        locationManager.requestAlwaysAuthorization()
        // 位置情報の精度を指定．任意，
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 位置情報取得間隔を指定．指定した値（メートル）移動したら位置情報を更新する．任意．
        // lm.distanceFilter = 1000
        
        // GPSの使用を開始する
        locationManager.startUpdatingLocation()
        
        destination = CLLocation(latitude: destinationLatitude, longitude: destinationLongitude)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* 位置情報取得成功時に実行される関数 */
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        destination = CLLocation(latitude: destinationLatitude, longitude: destinationLongitude)
        //緯度
        latitude = newLocation.coordinate.latitude
        //経度
        longitude = newLocation.coordinate.longitude
        //現在地の位置情報
        let currentLocation: CLLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        // 取得した緯度・経度をLogに表示
        //NSLog("latiitude: \(latitude) , longitude: \(longitude)")
        let distance = destination.distanceFromLocation(currentLocation)
        print(distance)
        
        distanceLabel.text = String(format: "%0.2f", Float(distance)) + "m"
        // GPSの使用を停止する．停止しない限りGPSは実行され，指定間隔で更新され続ける．
        locationManager.stopUpdatingLocation()
    }
    
    /* 位置情報取得失敗時に実行される関数 */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // この例ではLogにErrorと表示するだけ．
        NSLog("Error")
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        return destinations.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return "\(destinations[row])"
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.destinationLabel.text = destinations[row] + "まで"
        
        switch destinations[row] {
        case "日野キャン":
            //destinationLatitude = 35.66201
            //destinationLongitude = 139.366313
            //教室
            destinationLatitude = 35.661239
            destinationLongitude = 139.365425
        case "南大沢キャン":
            destinationLatitude = 35.61715
            destinationLongitude = 139.377004
        case "荒川キャン":
            destinationLatitude = 35.750152
            destinationLongitude = 139.77184
        case "新宿サテライト":
            destinationLatitude = 35.689815
            destinationLongitude = 139.691637
        default:
            break
        }
        locationManager.startUpdatingLocation()
    }
    

    @IBAction func update(sender: AnyObject) {
        locationManager.startUpdatingLocation()
    }
 
    
}

