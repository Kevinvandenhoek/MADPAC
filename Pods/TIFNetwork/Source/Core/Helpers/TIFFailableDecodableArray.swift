//
//  TIFFailableDecodableArray.swift
//  TIFNetwork
//
//  Created by Stef Kampen on 29/03/2018.
//

public struct TIFFailableDecodableArray<Element : Decodable> : Decodable {

    public let elements: [Element]

    public init(from decoder: Decoder) {
        guard var container = try? decoder.unkeyedContainer(), let count = container.count else {
            self.elements = []
            return
        }

        var elements = [Element]()
        elements.reserveCapacity(count)

        while !container.isAtEnd {
            if let element = (try? container.decode(TIFFailableDecodable<Element>.self))?.base {
                elements.append(element)
            }
        }
        self.elements = elements
    }
}
