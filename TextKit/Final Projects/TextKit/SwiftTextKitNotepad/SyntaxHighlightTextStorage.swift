/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class SyntaxHighlightTextStorage: NSTextStorage {
  let backingStore = NSMutableAttributedString()
  var replacements: [String : [NSObject : AnyObject]]!

  override init() {
    super.init()
    createHighlightPatterns()
  }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
  }
  
    override var string: String {
    return backingStore.string
  }

   
   override func attributes(at index: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedStringKey : Any] {
        return backingStore.attributes(at: index, effectiveRange: range)
  }

    override func replaceCharacters(in range: NSRange, with str: String) {
    print ("replaceCharactersInRange:\(range) withString:\(str)")

    beginEditing()
        backingStore.replaceCharacters(in: range, with:str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
        
    endEditing()
  }

    override func setAttributes(_ attrs: [NSAttributedStringKey : Any]?, range: NSRange) {
        print ("setAttributes:\(String(describing: attrs)) range:\(range)")
        
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }

  func applyStylesToRange(searchRange: NSRange) {
    let normalAttrs = [NSAttributedStringKey.font : UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]

    // iterate over each replacement
    for (pattern, attributes) in replacements {
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
        
        regex.enumerateMatches(in: backingStore.string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: searchRange) {
            match, flags, stop in
            
        // apply the style
            let matchRange = match?.range(at: 1)
            self.addAttributes(attributes as! [NSAttributedStringKey : Any], range: matchRange!)

        // reset the style to the original
        let maxRange = (matchRange?.location)! + (matchRange?.length)!
            if maxRange + 1 < self.length {
                self.addAttributes(normalAttrs, range: NSMakeRange(maxRange, 1))
            }
      }
    }
  }
    
    
  func performReplacementsForRange(changedRange: NSRange) {
    var extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRange(for: NSMakeRange(changedRange.location, 0)))
    extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRange(for: NSMakeRange(NSMaxRange(changedRange), 0)))
    applyStylesToRange(searchRange: extendedRange)
  }

  override func processEditing() {
    performReplacementsForRange(changedRange: self.editedRange)
    super.processEditing()
  }

  func createAttributesForFontStyle(style: String, withTrait trait: UIFontDescriptorSymbolicTraits) -> [NSObject : AnyObject] {
    let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
    let descriptorWithTrait = fontDescriptor.withSymbolicTraits(trait)
    let font = UIFont(descriptor: descriptorWithTrait!, size: 0)
    return [NSAttributedStringKey.font as NSObject : font]
  }

  func createHighlightPatterns() {
    
  
    let scriptFontDescriptor = UIFontDescriptor(name: "Zapfino", size: 12)

    // 1. base our script font on the preferred body font size
    let bodyFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
    let bodyFontSize = bodyFontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.size] as! NSNumber
    let scriptFont = UIFont(descriptor: scriptFontDescriptor, size: CGFloat(bodyFontSize.floatValue))

    // 2. create the attributes
    let boldAttributes = createAttributesForFontStyle(style: UIFontTextStyle.body.rawValue, withTrait:.traitBold)
    let italicAttributes = createAttributesForFontStyle(style: UIFontTextStyle.body.rawValue, withTrait:.traitItalic)
    let strikeThroughAttributes =  [NSAttributedStringKey.strikethroughStyle : 1]
    let scriptAttributes =  [NSAttributedStringKey.font : scriptFont]
    let redTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.red]

    // construct a dictionary of replacements based on regexes
    replacements = [
      "(\\*\\w+(\\s\\w+)*\\*)" : boldAttributes,
      "(_\\w+(\\s\\w+)*_)" : italicAttributes,
      "([0-9]+\\.)\\s" : boldAttributes,
      "(-\\w+(\\s\\w+)*-)" : strikeThroughAttributes,
      "(~\\w+(\\s\\w+)*~)" : scriptAttributes,
      "\\s([A-Z]{2,})\\s" : redTextAttributes
        ] as! [String : [NSObject : AnyObject]]
  }

  func update() {
    // update the highlight patterns
    createHighlightPatterns()

    // change the 'global' font
    
    let bodyFont = [NSAttributedStringKey.font : UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
    addAttributes(bodyFont, range: NSMakeRange(0, length))

    // re-apply the regex matches
    applyStylesToRange(searchRange: NSMakeRange(0, length))
  }

}
