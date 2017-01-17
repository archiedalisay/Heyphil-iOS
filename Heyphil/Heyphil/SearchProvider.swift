//
//  SearchProvider.swift
//  Heyphil
//
//  Created by Philcare on 14/12/2016.
//  Copyright © 2016 Philcare. All rights reserved.
//

import UIKit
import GoogleMaps
class SearchProvider: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        GMSServices.provideAPIKey("AIzaSyA2tWvKy9uZBm_slk606AmIbSV8aC3MiLg")
        let camera = GMSCameraPosition.camera(withLatitude: 12.8797, longitude: 121.7740, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView        // Creates a marker in the center of the map.
        
        let url=URL(string:"https://apps.philcare.com.ph/PhilcareWatsonTest/providers.svc/HospitalsPerMember/?Location=Makati&area=&Certno=5443460")
        do {
            let allContactsData = try? Data(contentsOf: url!)
            let allContacts = try JSONSerialization.jsonObject(with: allContactsData!, options: JSONSerialization.ReadingOptions.allowFragments)
                as! [String : AnyObject]
            if let arrJSON = allContacts["SearchHospitalsPerMemberResult"] as? NSArray{
                for index in 0...arrJSON.count-1 {
                    let aObject = arrJSON[index] as! [String : AnyObject]
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: Double(aObject["Latitude"] as! String)!, longitude: Double(aObject["Longitude"] as! String)!)
                    marker.title = "Sydney"
                    marker.snippet = "Australia"
                    marker.map = mapView
                    mapView.selectedMarker = marker                }
            }
        }
        catch
        {
        }

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
