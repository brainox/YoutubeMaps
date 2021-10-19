//
//  ViewController.swift
//  YoutubeMaps
//
//  Created by Decagon on 19/10/2021.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    let mapView = MKMapView()
    
    let searchVC = UISearchController(searchResultsController: ResultsViewController() )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Maps"
        view.addSubview(mapView)
        searchVC.searchBar.backgroundColor = .secondarySystemBackground
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsVC = searchController.searchResultsController as? ResultsViewController
        else {
            return
        }
        resultsVC.delegate = self
        
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                print(places)
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

extension ViewController: ResultsViewControllerDelegate {
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        //cancel the search controller after a completed search
        searchVC.dismiss(animated: true, completion: nil)
        //Remove all map pins
        let annotations = mapView.annotations
        
        mapView.removeAnnotations(annotations)
        
        // Add a map pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)), animated: true)
    }
}
