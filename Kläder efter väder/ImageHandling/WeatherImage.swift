//
//  WeatherImage.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-11-29.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit

enum Season{
    case summer
    case winter
    case spring
    case autumn
    
    public static let allValues = [summer, winter, spring, autumn]
    
    static var current: Season {
        //Gives the current day number since the start of the year. If not available, returns a number for summer images
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 200
        switch true {
        case dayOfYear>341:
            return .winter
        case dayOfYear>273:
            return .autumn
        case dayOfYear>131:
            return .summer
        case dayOfYear>76:
            return .spring
        default:
            return .winter
            
        }
    }
}

enum WeatherSymbol{
    case ClearSky(season:Season)
    case NearlyclearSky(season:Season)
    case Variablecloudiness(season:Season)
    case HalfclearSky(season:Season)
    case CloudySky(season:Season)
    case Overcast(season:Season)
    case Fog(season:Season)
    case Rainshowers(season:Season)
    case Thunderstorm(season:Season)
    case Lightsleet(season:Season)
    case Snowshowers(season:Season)
    case Rain(season:Season)
    case Thunder(season:Season)
    case Sleet(season:Season)
    case Snowfall(season:Season)
    
    
    static func create(rawValue: Int, season:Season) -> WeatherSymbol? {
        switch rawValue {
        case 1: return .ClearSky(season: season)
        case 2: return .NearlyclearSky(season: season)
        case 3: return .Variablecloudiness(season: season)
        case 4: return .HalfclearSky(season: season)
        case 5: return .CloudySky(season: season)
        case 6: return .Overcast(season: season)
        case 7: return .Fog(season: season)
        case 8: return .Rainshowers(season: season)
        case 9: return .Thunderstorm(season: season)
        case 10: return .Lightsleet(season: season)
        case 11: return .Snowshowers(season: season)
        case 12: return .Rain(season: season)
        case 13: return .Thunder(season: season)
        case 14: return .Sleet(season: season)
        case 15: return .Snowfall(season: season)
        default: return nil
        }
    }
    static func create(rawValue: Int) -> WeatherSymbol? {
        let season = Season.current
        return create(rawValue: rawValue, season: season)
    }
    var priority: Int{
        get{
            switch self {
            case .ClearSky: return 1
            case .NearlyclearSky: return 2
            case .Variablecloudiness: return 3
            case .HalfclearSky: return 4
            case .CloudySky: return 5
            case .Overcast: return 6
            case .Fog: return 7
            case .Rainshowers: return 8
            case .Rain: return 9
            case .Snowshowers: return 10
            case .Snowfall: return 11
            case .Thunderstorm: return 12
            case .Thunder: return 13
            case .Lightsleet: return 14
            case .Sleet: return 15
            }
        }
    }
    
    
    func stringRepresentation() -> String{
        switch self {
        case .ClearSky: return "Klart"
        case .NearlyclearSky: return "Mest klart"
        case .Variablecloudiness: return "Växlande molnighet"
        case .HalfclearSky: return "Halvklart"
        case .CloudySky: return "Molnigt"
        case .Overcast: return "Mulet"
        case .Fog: return "Dimma"
        case .Rainshowers: return "Regnskur"
        case .Thunderstorm: return "Åskskurar"
        case .Lightsleet: return "Byar av snöblandat regn"
        case .Snowshowers: return "Snöbyar"
        case .Rain: return "Regn"
        case .Thunder: return "Åska"
        case .Sleet: return "Snöblandat regn"
        case .Snowfall: return "Snöfall"
        }
    }
    
    func imageRepresentation() -> UIImage {
        // The gigantic switch is there to allow maximum customizability to pick images for weather. And to allow reuse of images where relevant.
        switch self {
        case .ClearSky(.winter): return #imageLiteral(resourceName: "vinter_klart")
        case .NearlyclearSky(.winter): return #imageLiteral(resourceName: "vinter_mest_klart")
        case .Variablecloudiness(.winter): return #imageLiteral(resourceName: "vinter_vaxlandemolnighet")
        case .HalfclearSky(.winter): return #imageLiteral(resourceName: "vinter_vaxlandemolnighet")
        case .CloudySky(.winter): return #imageLiteral(resourceName: "vinter_molnigt")
        case .Overcast(.winter): return #imageLiteral(resourceName: "vinter_regnskur_byarsnoblandat_askskurar")
        case .Fog(.winter): return #imageLiteral(resourceName: "vinter_dimma")
        case .Rainshowers(.winter): return #imageLiteral(resourceName: "vinter_regnskur_byarsnoblandat_askskurar")
        case .Thunderstorm(.winter): return #imageLiteral(resourceName: "vinter_regnskur_byarsnoblandat_askskurar")
        case .Lightsleet(.winter): return #imageLiteral(resourceName: "vinter_regn_mulet_snoblandat_aska")
        case .Snowshowers(.winter): return #imageLiteral(resourceName: "vinter_regnskur_byarsnoblandat_askskurar")
        case .Rain(.winter): return #imageLiteral(resourceName: "vinter_regn_mulet_snoblandat_aska")
        case .Thunder(.winter): return #imageLiteral(resourceName: "vinter_regn_mulet_snoblandat_aska")
        case .Sleet(.winter): return #imageLiteral(resourceName: "vinter_regn_mulet_snoblandat_aska")
        case .Snowfall(.winter): return #imageLiteral(resourceName: "host_vaxlandemolnighet")
            
        case .ClearSky(.spring): return #imageLiteral(resourceName: "var_klart")
        case .NearlyclearSky(.spring): return #imageLiteral(resourceName: "var_mest_klart")
        case .Variablecloudiness(.spring): return #imageLiteral(resourceName: "var_vaxlandemolnighet")
        case .HalfclearSky(.spring): return #imageLiteral(resourceName: "var_vaxlandemolnighet")
        case .CloudySky(.spring): return #imageLiteral(resourceName: "var_molnigt")
        case .Overcast(.spring): return #imageLiteral(resourceName: "var_regn_mulet_snoblandat_aska")
        case .Fog(.spring): return #imageLiteral(resourceName: "var_dimma")
        case .Rainshowers(.spring): return #imageLiteral(resourceName: "var_regnskur_byarsnoblandat_askskurar")
        case .Thunderstorm(.spring): return #imageLiteral(resourceName: "var_regnskur_byarsnoblandat_askskurar")
        case .Lightsleet(.spring): return #imageLiteral(resourceName: "var_regn_mulet_snoblandat_aska")
        case .Snowshowers(.spring): return #imageLiteral(resourceName: "var_regnskur_byarsnoblandat_askskurar")
        case .Rain(.spring): return #imageLiteral(resourceName: "var_regn_mulet_snoblandat_aska")
        case .Thunder(.spring): return #imageLiteral(resourceName: "var_regn_mulet_snoblandat_aska")
        case .Sleet(.spring): return #imageLiteral(resourceName: "var_regn_mulet_snoblandat_aska")
        case .Snowfall(.spring): return #imageLiteral(resourceName: "var_regn_mulet_snoblandat_aska")
            
        case .ClearSky(.summer): return #imageLiteral(resourceName: "sommar_klart")
        case .NearlyclearSky(.summer): return #imageLiteral(resourceName: "sommar_mest_klart")
        case .Variablecloudiness(.summer): return #imageLiteral(resourceName: "sommar_vaxlandemolnighet")
        case .HalfclearSky(.summer): return #imageLiteral(resourceName: "sommar_vaxlandemolnighet")
        case .CloudySky(.summer): return #imageLiteral(resourceName: "sommar_molnigt")
        case .Overcast(.summer): return #imageLiteral(resourceName: "sommar_regn_mulet_aska")
        case .Fog(.summer): return #imageLiteral(resourceName: "sommar_dimma")
        case .Rainshowers(.summer): return #imageLiteral(resourceName: "sommar_regnskur_askskurar")
        case .Thunderstorm(.summer): return #imageLiteral(resourceName: "sommar_regnskur_askskurar")
        case .Lightsleet(.summer): return #imageLiteral(resourceName: "sommar_regnskur_askskurar")
        case .Snowshowers(.summer): return #imageLiteral(resourceName: "sommar_regnskur_askskurar")
        case .Rain(.summer): return #imageLiteral(resourceName: "sommar_regn_mulet_aska")
        case .Thunder(.summer): return #imageLiteral(resourceName: "sommar_regn_mulet_aska")
        case .Sleet(.summer): return #imageLiteral(resourceName: "sommar_regn_mulet_aska")
        case .Snowfall(.summer): return #imageLiteral(resourceName: "sommar_regn_mulet_aska")
            
        case .ClearSky(.autumn): return #imageLiteral(resourceName: "host_klart")
        case .NearlyclearSky(.autumn): return #imageLiteral(resourceName: "host_mest_klart")
        case .Variablecloudiness(.autumn): return #imageLiteral(resourceName: "host_vaxlandemolnighet")
        case .HalfclearSky(.autumn): return #imageLiteral(resourceName: "host_vaxlandemolnighet")
        case .CloudySky(.autumn): return #imageLiteral(resourceName: "host_molnigt")
        case .Overcast(.autumn): return #imageLiteral(resourceName: "host_regn__snoblandat_mulet_aska")
        case .Fog(.autumn): return #imageLiteral(resourceName: "host_dimma")
        case .Rainshowers(.autumn): return #imageLiteral(resourceName: "host_regnskur_snobyar_askskurar")
        case .Thunderstorm(.autumn): return #imageLiteral(resourceName: "host_regnskur_snobyar_askskurar")
        case .Lightsleet(.autumn): return #imageLiteral(resourceName: "host_regn__snoblandat_mulet_aska")
        case .Snowshowers(.autumn): return #imageLiteral(resourceName: "host_regnskur_snobyar_askskurar")
        case .Rain(.autumn): return #imageLiteral(resourceName: "host_regn__snoblandat_mulet_aska")
        case .Thunder(.autumn): return #imageLiteral(resourceName: "host_regn__snoblandat_mulet_aska")
        case .Sleet(.autumn): return #imageLiteral(resourceName: "host_regn__snoblandat_mulet_aska")
        case .Snowfall(.autumn): return #imageLiteral(resourceName: "host_regn__snoblandat_mulet_aska")

        }
    }
}
