//
//  EmojiUtils.swift
//  MiniChat
//
//  Created by pavel on 9/25/18.
//  Copyright © 2018 Pavel. All rights reserved.
//

import UIKit
@objcMembers
class EmojiUtils: NSObject {
    static func emojis(str:String)->[String] {         // @objc
        return str.emojis;
    }
    static func containsOnlyEmoji(str:String)->Bool {         // @objc
        return str.emojiString == str;
    }
    static func emojiString(str:String)->String {         // @objc
        return str.emojiString;
    }

    static func glyphCount(str:String)->Int {         // @objc
        return str.glyphCount;
    }
}

extension UnicodeScalar {

    var isEmoji: Bool {

        switch value {
        case 0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        0x1F1E6...0x1F1FF, // Regional country flags
        0x2600...0x26FF,   // Misc symbols
        0x2700...0x27BF,   // Dingbats
        0xFE00...0xFE0F,   // Variation Selectors
        0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
        127000...127600, // Various asian and nigers characters
        65024...65039, // Variation selector
        9100...9300, // Misc items
        8400...8447,// Combining Diacritical Marks for Symbols
        0xE007F, //cancel tag emoji
        0xE0061...0xE007A://Extra letter for flags
        return true

        default: return false
        }
    }

    var isZeroWidthJoiner: Bool {

        return value == 8205
    }

    var isSkinModifier:Bool
    {
        switch value {
        case 0x1F3FB...0x1F3FF:
            return true
        default:
            return false
        }
    }


    var isExtraLetterForFlags:Bool
    {
        switch value {
        case 0xE0061...0xE007A:
            return true
        default:
            return false
        }
    }

    var isArrow:Bool
    {
        switch value {
        case 0x2194...0x2B07:
            return true
        default:
            return false
        }
    }

    var isEnclosingKeyup:Bool
    {
        return value == 8419
    }

    var isCancelTagEmoji:Bool
    {
        return value == 917631
    }

    var isFlagLetter:Bool
    {
        switch value {
        case 0x1F1E6...0x1F1FF:
            return true
        default:
            return false
        }
    }

    var isDigitLetter:Bool
    {
        switch value {
        case 0x30...0x39:
            return true
        default:
            return false
        }
    }

    var isPlainTextUncodeInFutureConvertedToEmoji:Bool
    {
        switch value {
        case 0x2122:
            return true
        case 0xA9:
            return true
        case 0xAE:
            return true
        case 0x203C:
            return true;
        case 0x2049:
            return true;
        default:
            return false
        }
    }

    var isInvisibleVariationSelector:Bool
    {
        return value == 65039
    }
}

extension String {

    var glyphCount: Int {

        let richText = NSAttributedString(string: self)
        let line = CTLineCreateWithAttributedString(richText)
        return CTLineGetGlyphCount(line)
    }

    var isSingleEmoji: Bool {

        return glyphCount == 1 && containsEmoji
    }

    var containsEmoji: Bool {

        return unicodeScalars.contains { $0.isEmoji }
    }

    var containsOnlyEmoji: Bool {

        return !isEmpty
            && !unicodeScalars.contains(where: {
               /* print($0.isEmoji)
                print($0.isZeroWidthJoiner)
                print($0.isCancelTagEmoji)
                print($0.isInvisibleVariationSelector)
                print($0.isEnclosingKeyup)
                print($0.isDigitLetter)
                print($0.isArrow)
                return false*/
                !$0.isEmoji
                && !$0.isZeroWidthJoiner
                && !$0.isCancelTagEmoji
                && !$0.isInvisibleVariationSelector
                && !$0.isEnclosingKeyup
                && !$0.isDigitLetter
                && !$0.isArrow
                && !$0.isPlainTextUncodeInFutureConvertedToEmoji
            })
    }

    var emojiString: String {

        return emojiScalars.map { String($0) }.reduce("", +)
    }

    var emojis: [String] {

        var scalars: [[UnicodeScalar]] = []
        var currentScalarSet: [UnicodeScalar] = []
        var previousScalar: UnicodeScalar?
        var flagCharCount:Int = 0;
        for scalar in emojiScalars {
            /*print(scalar);
            print(scalar.isZeroWidthJoiner);
            print(scalar.isSkinModifier);
            print(scalar.isInvisibleVariationSelector);
            print(scalar.isCancelTagEmoji);
            print(scalar.isEnclosingKeyup);
            print(scalar.isFlagLetter);
            print(scalar.isExtraLetterForFlags);*/
            if let prev = previousScalar, ( !prev.isZeroWidthJoiner &&
                                            !scalar.isZeroWidthJoiner &&
                                            !scalar.isInvisibleVariationSelector &&
                                            !scalar.isSkinModifier && !scalar.isFlagLetter &&
                                            !scalar.isExtraLetterForFlags && !scalar.isCancelTagEmoji &&
                                            !scalar.isEnclosingKeyup) ||
                                            (scalar.isFlagLetter && prev.isFlagLetter && flagCharCount == 2) ||
                                            (scalar.isFlagLetter && !prev.isFlagLetter) ||
                                            (prev.isCancelTagEmoji && !scalar.isCancelTagEmoji) ||
                                            (prev.isEnclosingKeyup && !scalar.isEnclosingKeyup) {


                scalars.append(currentScalarSet)
                currentScalarSet = []
                flagCharCount = 0
            }
            if(scalar.isFlagLetter)
            {
                flagCharCount += 1
            }
            currentScalarSet.append(scalar)
            print(currentScalarSet);
            previousScalar = scalar
        }

        scalars.append(currentScalarSet)
        print(scalars);
        return scalars.map { $0.map{ String($0) } .reduce("", +) }
    }

    fileprivate var emojiScalars: [UnicodeScalar] {

        var chars: [UnicodeScalar] = []
        var previous: UnicodeScalar?
        for cur in unicodeScalars {
            print(cur);
            print(cur.isZeroWidthJoiner);
            if let previous = previous, (previous.isZeroWidthJoiner && cur.isEmoji) || (cur.isEnclosingKeyup && !previous.isEmoji) || (cur.isInvisibleVariationSelector && !previous.isEmoji) {
                //print(previous);
                //print(previous.isZeroWidthJoiner);
                chars.append(previous)
                chars.append(cur)

            } else if cur.isEmoji {
                chars.append(cur)
            }
            print(chars);
            previous = cur
        }

        return chars
    }
}
