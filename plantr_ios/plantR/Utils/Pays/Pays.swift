//
//  Pays.swift
//  plantR_ios
//
//  Created by Adison Pereira de oliveira on 30/03/2022.
//  Copyright © 2022 Agrove. All rights reserved.
//

import Foundation

class PaysUtils {
    var pays : AllPays
    
    init(){
        if let path = Bundle.main.url(forResource: "pays", withExtension: "json") {
            do {
                let data = try Data(contentsOf: path)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(AllPays.self, from: data)
                self.pays = jsonData
                  
              } catch {
                  self.pays = AllPays(data: [Pays]())
              }
        }else{
            self.pays = AllPays(data: [Pays]())
        }
    }
    
    func paysIsValid(pays: String) -> Bool {
        return self.pays.data.contains(where: {$0.name.lowercased() == pays.lowercased()})
    }
    
    func getPaysName() -> [String] {
        return self.pays.data.map({$0.name})
    }
    
    func getCodeByName(name : String) -> String {
        return self.pays.data.filter({$0.name == name}).first?.code ?? "fr"
    }
    
    func getNameByCode(code: String) -> String {
        return self.pays.data.filter({$0.code == code}).first?.name ?? "France"
    }
    
}
struct AllPays : Decodable {
    var data : [Pays]
}
struct Pays: Decodable {
    var name : String
    var code : String
}
