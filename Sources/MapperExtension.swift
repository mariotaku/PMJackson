//
//  MapperExtension.swift
//  PMJackson
//
//  Created by Mariotaku Lee on 2017/6/7.
//  Copyright © 2017年 Postmates. All rights reserved.
//
import PMJSON

public extension JsonMapper {
    public func parseArray(_ parser: JsonParser) -> [T] {
        var array = [T]()
        if (parser.currentEvent == .arrayStart) {
            while (parser.nextEvent() != .arrayEnd) {
                array.append(parse(parser))
            }
        }
        return array
    }
    
    public func parseDict(_ parser: JsonParser) -> [String: T] {
        var dict = [String: T]()
        while (parser.nextEvent() != .objectEnd) {
            let key = parser.getText()
            parser.nextEvent()
            if (parser.currentEvent != .nullValue) {
                dict[key] = parse(parser)
            }
        }
        return dict
    }
    
    public func parseOptionalDict(_ parser: JsonParser) -> [String: T?] {
        var dict = [String: T?]()
        while (parser.nextEvent() != .objectEnd) {
            let key = parser.getText()
            parser.nextEvent()
            if (parser.currentEvent == .nullValue) {
                dict[key] = nil
            } else {
                dict[key] = parse(parser)
            }
        }
        return dict
    }
}
