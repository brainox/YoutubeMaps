//
//  GooglePlacesManager.swift
//  YoutubeMaps
//
//  Created by Decagon on 19/10/2021.
//

import Foundation
import GooglePlaces
import CoreLocation

final class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    
    private let client = GMSPlacesClient.shared()
    
    private init() {
        
    }

    public func findPlaces(
        query: String,
        completion: @escaping (Result<[Place], Error>) -> Void)
    {
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { results, error in
            
            guard let results = results, error == nil else {
                completion(.failure(PlacesError.failedToFind))
                return
            }
            
            let places: [Place] = results.compactMap {
                Place(
                    name: $0.attributedFullText.string,
                    identifier: $0.placeID
                )
            }
            completion(.success(places))
        }
    }
    
    public func resolveLocation(place: Place, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        
        client.fetchPlace(fromPlaceID: place.identifier, placeFields: .coordinate, sessionToken: nil) { targetPlace, error in
            
            guard let targetPlace = targetPlace, error == nil else {
                completion(.failure(PlacesError.failedToGetCoordinates))
                return
            }
            
            let coordinates = CLLocationCoordinate2D(
                latitude: targetPlace.coordinate.latitude,
                longitude: targetPlace.coordinate.longitude
            )
            
            completion(.success(coordinates))
        }
    }
}
