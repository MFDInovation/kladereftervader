//
//  Constants.swift
//  Kläder efter väder
//
//  Created by test on 2017-08-10.
//  Copyright © 2017 Knowit. All rights reserved.
//

import Foundation
import UIKit
struct constants {

    static let showDebugBorders: Bool = false

    static let displayWidth: CGFloat = UIScreen.main.bounds.width
    static let displayHeight: CGFloat = UIScreen.main.bounds.height
    
    static let startHelptText = "Kläder efter väder är en app som visar vilka kläder man bör ha för dagens väder. Väderprognosen för hela dagen hämtas från väderlekstjänsten SMHI och är anpassad till den plats man befinner sig på.\n\nAppen visar vilken temperatur och vilket väder det kommer att bli under dagen. Appen visar det sämsta vädret som kommer att inträffa under de nästkommande 8 timmarna. Till exempel om det kommer att regna en kort stund, så visar appen att man kan behöva regnkläder.\n\nMan kan också ta egna bilder på sina kläder som man ska ha för olika typer av väder och temperaturer. Tryck på knappen \"Hantera bilder\" för att lägga till bilder som du fotograferat med din mobiltelefon eller surfplatta."
    
    static let changeClothesHelpText = "För att lägga till en egen bild måste du först ha fotograferat lite olika kläder med din mobiltelefon eller surfplatta.\n\nUnder \"Hantera bilder\" väljer du vilken typ av temperatur och väderlek som kläderna skall visas för. Du bläddrar mellan olika temperaturer och väderlekar genom att svepa med fingret på skärmen.\n\nNär du har valt temperatur och väderlek så trycker du på knappen \"Lägg till\" längst ner på skärmen. Du kommer då att kunna välja en bild som du fotograferat. Du kan välja flera bilder till varje typ av väderlek, och ta bort dem med knappen \"Ta bort\" om det skulle bli fel. När väderleken sedan inträffar så kan du bläddra mellan alla de bilder du lagt till."
    
    static func getClothingName(_ clothingValue: Clothing?) -> String {
        var clothingName = String()
        if let clothing = clothingValue {
            switch clothing {
                case .mycketKallt:
                    clothingName = "Under -15°"
                case .mycketKalltSno :
                    clothingName = "Under -15°, snö"
                case .kallt:
                    clothingName = "-15° till -5°"
                case .kalltSno:
                    clothingName = "-15° till -5°, snö"
                case .nollgradigtMinus:
                    clothingName = "-5° till 0°"
                case .nollgradigtMinusSno:
                    clothingName = "-5° till 0°, snö"
                case .nollgradigtPlus:
                    clothingName = "0° till 5°" 
                case .nollgradigtPlusRegn:
                    clothingName = "0° till 5°, regn"
                case .kyligt:
                    clothingName = "5° till 15°"
                case .kyligtRegn:
                    clothingName = "5° till 15°, regn"
                case .varmt:
                    clothingName = "15° till 25°"
                case .varmtRegn:
                    clothingName = "15° till 25°, regn"
                case .hett:
                    clothingName = "Över 25°"
                case .hettRegn:
                    clothingName = "Över 25°, regn"
                case .errorNetwork, .errorGPS:
                    clothingName = "Okänt"
            }
        }
        return clothingName
    }

    static func isLandscapeEnabled() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad  // Only iPads support landscape orientation
    }
}
