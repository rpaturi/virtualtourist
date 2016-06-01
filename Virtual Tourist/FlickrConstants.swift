//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Rachel Paturi on 5/31/16.
//  Copyright © 2016 Rachel Paturi. All rights reserved.
//

import Foundation

extension FlickrClient {
    struct FlickrURL {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
    }
    
    struct Method {
        static let PhotoSearch = "flickr.photos.search"
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    struct FlickrParameterValues {
        static let APIKey = "a69a4947c4bf639fc000557149a794e3"
        static let FormatResponse = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let PhotoSearchMethod = "flickr.photos.search"
    }
}