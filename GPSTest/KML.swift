//
//  KMLData.swift
//  GPSTest
//
//  Created by 山本隼也 on 2016/10/27.
//  Copyright © 2016年 山本隼也. All rights reserved.
//

import Foundation

struct Coordinates{
    var latitude : Double
    var longitude : Double
}

struct LocationData{
    var location:Coordinates
    var name:String?
    var url:String?
}

class KML{
    
    var loData:[LocationData] = []
    
    init(fileName:String) {
        let fileString : String
        do{
            fileString = try String(contentsOfFile: fileName, encoding: NSUTF8StringEncoding)
        }
        catch{
            return
        }
        
        var placesData = fileString.componentsSeparatedByString("<Placemark>")
        placesData.removeAtIndex(0)
        for placeData in placesData {
            var name:String? = nil
            var url:String? = nil
            let place = placeData.componentsSeparatedByString("</Placemark>")
            
            //name
            if place[0].lowercaseString.containsString("<name>"){
                let name1 = place[0].componentsSeparatedByString("<name>")
                let name2 = name1[1].componentsSeparatedByString("</name>")
                name = name2[0]
                print(name2[0])
            }
            //画像url
            
            if place[0].lowercaseString.containsString("<description>"){
                let description1 = place[0].componentsSeparatedByString("<description>")
                let description2 = description1[1].componentsSeparatedByString("</description>")
                if description2[0].lowercaseString.containsString("img"){
                    let url1 = place[0].componentsSeparatedByString("<img src=\"")
                    let url2 = url1[1].componentsSeparatedByString("\"/>")
                    url = url2[0]
                    print(url2[0])
                }
                
            }
            //座標
            if place[0].lowercaseString.containsString("<coordinates>"){
                let coordinates1 = place[0].componentsSeparatedByString("<coordinates>")
                let coordinates2 = coordinates1[1].componentsSeparatedByString("</coordinates>")
                let coordinate = coordinates2[0].componentsSeparatedByString(",")
                let long = Double(coordinate[0])!
                let lat = Double(coordinate[1])!
                let location:Coordinates = Coordinates(latitude: lat, longitude: long)
                print(location)
                loData.append(LocationData(location: location, name: name, url: url))
            }
            
        }
        
    }
}
