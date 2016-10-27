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
    var destLoc:CLLocationCoordinate2D!
    
    //行き先の位置情報
    var destinations:[String] = []
    var destination: CLLocation!
    
    var kml:KML!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!

    @IBOutlet weak var compassImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let fileName = NSBundle.mainBundle().pathForResource("KMLTest", ofType: "kml") {
            kml = KML(fileName: fileName)
        }else{
            fatalError("Failed to initialize Stations")
        }
        for data in kml.loData{
            if let name = data.name{
            destinations.append(name)
            }
            
        }
        destLoc = CLLocationCoordinate2D(latitude: kml.loData[0].location.latitude, longitude: kml.loData[0].location.longitude)
        
        self.destinationLabel.text = destinations[0] + "まで"
        
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
        //option
        // 位置情報取得間隔を指定．指定した値（メートル）移動したら位置情報を更新する．任意．
        // locationManager.distanceFilter = 1000
        //すべての動きを通知する
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        // GPSの使用を開始する
        locationManager.startUpdatingLocation()
        //コンパスの使用を開始する
        locationManager.startUpdatingHeading()
        
        destination = CLLocation(latitude: destLoc.latitude, longitude: destLoc.longitude)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* 位置情報取得成功時に実行される関数 */
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        destination = CLLocation(latitude: destLoc.latitude, longitude: destLoc.longitude)
        //緯度
        latitude = newLocation.coordinate.latitude
        //経度
        longitude = newLocation.coordinate.longitude
        //現在地の位置情報
        let currentLocation: CLLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        // 取得した緯度・経度をLogに表示
        //NSLog("latiitude: \(latitude) , longitude: \(longitude)")
        let distance = destination.distanceFromLocation(currentLocation)
        //print(distance)
        if distance < 1000{
            distanceLabel.text = String(format: "%d", Int(distance)) + "m"
        }else{
            distanceLabel.text = String(format: "%d", Int(distance/1000)) + "." + String(format: "%03d", Int(distance%1000)) + "km"
        }
        // GPSの使用を停止する．停止しない限りGPSは実行され，指定間隔で更新され続ける．
        locationManager.stopUpdatingLocation()
    }
    
    /* コンパス情報取得成功時に実行される関数 */
    func locationManager(manager:CLLocationManager, didUpdateHeading newHeading:CLHeading) {
        let accuracy = newHeading.headingAccuracy
        //print("accuracy: " + String(accuracy))
        if accuracy < 0 {
            return
        }
        let trueHeading = newHeading.trueHeading
        //let magneticHeading = newHeading.magneticHeading
        
        print("true    : " + String(trueHeading))
        //print("magnetic: " + String(magneticHeading))
        // 方位角を求める
        let azimuth:Double = CalculateAngle(self.latitude, lon1: self.longitude, lat2: destLoc.latitude, lon2: destLoc.longitude)*180/M_PI;
        let destinationAzimuth = trueHeading - azimuth;
        print("azimuth" + String(azimuth))
        print("destinationAzimuth" + String(destinationAzimuth))
        //degreeLabel.text = String(format: "%0.1f", Float(destinationAzimuth)) + "°"
        compassImageView.transform = CGAffineTransformMakeRotation(CGFloat(-destinationAzimuth)*CGFloat(M_PI)/180)
        
    }
    
    //緯度・経度から二点の距離を算出する
    func CalculateAngle(lat1:Double, lon1:Double, lat2:Double,lon2:Double) -> Double{
        let longitudinalDifference = lon2 - lon1;
        let latitudinalDifference  = lat2 - lat1;
        let azimuth = M_PI/2  - atan(latitudinalDifference / longitudinalDifference);
        if longitudinalDifference > 0 {
            return( azimuth )
        }else if longitudinalDifference < 0 {
            return( azimuth + M_PI );
        }else if latitudinalDifference < 0{
            return( M_PI );
        }else{
            return(0.0);
        }
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
        for data in kml.loData{
            if destinations[row] == data.name{
                destLoc = CLLocationCoordinate2D(latitude: data.location.latitude, longitude: data.location.longitude)
            }
        }
        /*
        switch destinations[row] {
        case "日野1号館":
            destLoc = CLLocationCoordinate2D(latitude: 35.661869, longitude: 139.366347)
        case "日野2号館":
            destLoc = CLLocationCoordinate2D(latitude: 35.661495, longitude: 139.367606)
        case "日野4号館":
            destLoc = CLLocationCoordinate2D(latitude: 35.661269, longitude: 139.365575)
        case "日野生協":
            destLoc = CLLocationCoordinate2D(latitude: 35.660474, longitude: 139.366279)
        case "日野庭園":
            destLoc = CLLocationCoordinate2D(latitude: 35.66116, longitude: 139.366565)
        case "南大沢キャン":
            destLoc = CLLocationCoordinate2D(latitude: 35.61715, longitude: 139.377004)
        case "荒川キャン":
            destLoc = CLLocationCoordinate2D(latitude: 35.750152, longitude: 139.77184)
        case "新宿サテライト":
            destLoc = CLLocationCoordinate2D(latitude: 35.689815, longitude: 139.691637)
        case "自宅":
            destLoc = CLLocationCoordinate2D(latitude: 35.619195, longitude: 139.385866)
        default:
            break
        }*/
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    

    @IBAction func update(sender: AnyObject) {
        locationManager.startUpdatingLocation()
    }
 
    
}

