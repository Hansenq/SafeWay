//
//  MapViewController.swift
//  SafeWay
//
//  Created by Hansen Qian on 7/11/15.
//  Copyright (c) 2015 HQ. All rights reserved.
//

import GoogleMaps
import SwiftyJSON
import UIKit

class MapViewController: UIViewController {

    let mapView: GMSMapView

    var polylines : Array<GMSPolyline>

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let cameraPosition = GMSCameraPosition.cameraWithLatitude(37.7771754, longitude: -122.4184106, zoom: 15)
        self.mapView = GMSMapView.mapWithFrame(CGRectZero, camera: cameraPosition)
        self.polylines = Array<GMSPolyline>()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.padding = UIEdgeInsetsMake(0, 0, 49, 0)
        self.mapView.settings.compassButton = true
        self.mapView.myLocationEnabled = true
        self.mapView.settings.myLocationButton = true

        self.view = UIView()
        self.view.addSubview(mapView)
        mapView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func displayRoutes(json: JSON) {
        self.polylines.map { [unowned self] line in
            line.map = nil
        }
        self.polylines = Array<GMSPolyline>()

        // Remove all current polylines
        var lines = Array<String>()
        for (index: String, obj: JSON) in json["routes"] {
            lines.append(obj["overview_polyline"]["points"].stringValue)
        }
        lines.map { [unowned self] line in
            self.displayPolyline(line, view: self.mapView, primary: line == lines.first)
        }
        println("\(json)")
        let neLat = json["routes"][0]["bounds"]["northeast"]["lat"].doubleValue
        let neLng = json["routes"][0]["bounds"]["northeast"]["lng"].doubleValue
        let swLat = json["routes"][0]["bounds"]["southwest"]["lat"].doubleValue
        let swLng = json["routes"][0]["bounds"]["southwest"]["lng"].doubleValue
        self.mapView.camera = self.mapView.cameraForBounds(
            GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(
                neLat,
                neLng
            ), coordinate: CLLocationCoordinate2DMake(
                swLat,
                swLng
            )), insets: UIEdgeInsetsMake(100, 100, 100, 100))

//        self.mapView.animateToZoom(calculateZoom(neLat, neLng: neLng, swLat: swLat, swLng: swLng));
        self.mapView.animateToZoom(13)
    }

//    func calculateZoom(neLat: Float, neLng: Float, swLat: Float, swLng: Float) -> Float {
//            var WORLD_DIM = [ "height": 256, "width": 256 ];
//            var ZOOM_MAX = 21;
//
//            var latFraction = (latRad(neLat) - latRad(swLat)) / M_PI;
//
//            var lngDiff = neLng - swLng;
//            var lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;
//
//            var latZoom = zoom(self.mapView.bounds.height, WORLD_DIM.height, latFraction);
//            var lngZoom = zoom(self.mapView.bounds.width, WORLD_DIM.width, lngFraction);
//            
//            return min(latZoom, lngZoom, ZOOM_MAX);
//    }
//    func latRad(lat: Float) {
//        var sin = sin(lat * M_PI / 180);
//        var radX2 = log((1 + sin) / (1 - sin)) / 2;
//        return max(min(radX2, M_PI), -M_PI) / 2;
//    }
//    func zoom(mapPx: Float, worldPx: Float, fraction: Float) {
//        return min(log(mapPx / worldPx / fraction) / log(2));
//    }

    func displayPolyline(line: String, view: GMSMapView, primary: Bool) {
        var line = GMSPolyline(path: GMSPath(fromEncodedPath: line))
        line.map = mapView
        line.strokeColor = (primary ? UIColor.blueColor() : UIColor.blackColor()).colorWithAlphaComponent(0.3)
        line.strokeWidth = 5
        self.polylines.append(line)
    }
}

