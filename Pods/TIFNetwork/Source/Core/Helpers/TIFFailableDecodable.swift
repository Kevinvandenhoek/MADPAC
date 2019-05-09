//
//  TIFFailableDecodable.swift
//  TIFNetwork
//
//  Created by Stef Kampen on 29/03/2018.
//

public struct TIFFailableDecodable<Base : Decodable> : Decodable {

    public let base: Base?

    public init(from decoder: Decoder) {
        let container = try? decoder.singleValueContainer()
        base = (try? container?.decode(Base.self)) ?? nil
    }
}
