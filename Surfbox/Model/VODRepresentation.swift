//
//  VODRepresentation.swift
//  Surfbox
//
//  Created by Moses Robinson on 3/14/19.
//  Copyright © 2019 Moses Robinson. All rights reserved.
//

import Foundation

struct VODRepresentation: Equatable, Codable {
    let title: String
    let id: Int
    let releaseYear: Int
    let rating: String
    let posterSmall: String
    let posterLarge: String
    var overview: String?
    var genres: [GenreReprensentation]?
    var sources: [SourceRepresentation]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case id
        case releaseYear = "release_year"
        case rating
        case posterSmall = "poster_240x342"
        case posterLarge = "poster_400x570"
        case overview
        case genres
        case sources = "subscription_ios_sources"
    }
    
}

struct GenreReprensentation: Equatable, Codable {
    var title: String
}

struct SourceRepresentation: Equatable, Codable {
    var appDownloadLink: String
    var appName: String
    var link: String
    
    enum CodingKeys: String, CodingKey {
        case appDownloadLink = "app_download_link"
        case appName = "app_name"
        case link
    }
}

struct VODRepresentations: Codable {
    let results: [VODRepresentation]
}

func ==(lhs: VODRepresentation , rhs: VOD) -> Bool {
    return lhs.title == rhs.title &&
        lhs.id == rhs.id &&
        lhs.releaseYear == rhs.releaseYear &&
        lhs.rating == rhs.rating &&
        lhs.posterSmall == rhs.posterSmall &&
        lhs.posterLarge == rhs.posterLarge &&
        lhs.overview == rhs.overview
}

func ==(lhs: VOD, rhs: VODRepresentation) -> Bool {
    return rhs == lhs
}

func !=(lhs: VODRepresentation , rhs: VOD) -> Bool {
    return !(rhs == lhs)
}

func !=(lhs: VOD, rhs: VODRepresentation) -> Bool {
    return rhs != lhs
}
