
# Screencast Metadata

-----

### Language, Editor and Platform versions used in these screencasts:

**Language:** Swift 4.1
**Platform:** iOS 11.4
**Editor**: Xcode 9.5

-----

### RW Screencast Title:
Getting Started with TextKit: Part 2

### Course Description:
Learn how to easily layout your text in iOS using Swift and Text Kit

TH - Intro
------------
Hi Everyone, and welcome to part 2 of 2 of Getting Started with Textkit

Let's dive right in. At the end of our last screencast, we started talking about Apple's behind the scenes work to create classes automatically for you. Behind the scenes, Apple creates classes automatically when you create a UITextView, UILabel or UITextField. In your apps, you can either use these default implementations or customize any part to get your own behavior. Let's go over each class:

Slide
---------
o NSTextStorage stores the text it is to render as an attributed string, and informs the layout manager of any changes to the text's contents. You might want to subclass NSTextStorage in order to dynamically change the text attributes as the text updates (as you will see later in this tutorial).
o NSLayoutManager takes the stored text and renders it on the screen; it serves as the layout 'engine' in your app.
o NSTextContainer describes the geometry of an area of the screen where the app renders text. Each text container is typically associated with a UITextView. You might want to subclass NSTextContainer to define a complex shape that you would like to render text within.


TH:
To implement the dynamic text formatting feature in this app, you'll need to subclass NSTextStorage in order to dynamically add text attributes as the user types in their text.
Once you've created your custom NSTextStorage, you'll replace UITextView's default text storage instance with your own implementation. Let's give this a shot!

Coding

Right-click on the SwiftTextKitNotepad group in the project navigator, select New File…, and choose iOS/Source/Cocoa Touch Class and click Next.
Name the class SyntaxHighlightTextStorage, make it a subclass of NSTextStorage, and confirm that the Language is set to Swift. Click Next, then Create.
Open SyntaxHighlightTextStorage.swift and add a new property inside the class declaration:

let backingStore = NSMutableAttributedString()

A text storage subclass must provide its own persistence hence the use of a NSMutableAttributedString backing store - more on this later.
Next add the following to the class:

    override var string: String {
        return backingStore.string
      }
    
      override func attributes(at index: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedStringKey : Any] {
            return backingStore.attributes(at: index, effectiveRange: range)
      }

The first of these two declarations overrides the string computed property, deferring to the backing store. Also, the attributesAtIndex method also delegates to the backing store.

Finally add the remaining mandatory overrides to the same file:


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
Again, these methods delegate to the backing store. However, they also surround the edits with calls to beginEditing, edited and endEditing. The text storage class requires these three methods in order to notify its associated layout manager when making edits.

Coding
--------
Now that you have a custom NSTextStorage, you need to make a UITextView that uses it.
A UITextView with a Custom Text Kit Stack
Instantiating UITextView from the storyboard editor automatically creates an instance of NSTextStorage, NSLayoutManager and NSTextContainer (i.e. the Text Kit stack) and exposes all three instances as read-only properties.
There is no way to change these from the storyboard editor, but luckily you can if you create the UITextView and Text Kit stack programatically.
Let's give this a shot. Open up Main.storyboard, and locate the NoteEditorViewController view by expanding Detail Scene/Detail/View and select Text View. Delete this UITextView instance.
Next, open NoteEditorViewController.swift and remove the UITextView outlet from the class and replace it with the following property declarations:


    var textView: UITextView!
    var textStorage: SyntaxHighlightTextStorage!

These two properties are for your text view and the custom storage subclass.
Next remove the following lines from viewDidLoad:

    textView.text = note.contents
    textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)

Since you are no longer using the outlet for the text view and will be creating one manually instead, you no longer need these lines.
Still working in NoteEditorViewController.swift, add the following method to the class:


func createTextView() {
    // 1. Create the text storage that backs the editor
    
    let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
    let attrString = NSAttributedString(string: note.contents, attributes: attrs)
    textStorage = SyntaxHighlightTextStorage()
    textStorage.append(attrString)

    let newTextViewRect = view.bounds

    // 2. Create the layout manager
    let layoutManager = NSLayoutManager()

    // 3. Create a text container
    let containerSize = CGSize(width: newTextViewRect.width, height: CGFloat.greatestFiniteMagnitude)
    let container = NSTextContainer(size: containerSize)
    container.widthTracksTextView = true
    layoutManager.addTextContainer(container)
    textStorage.addLayoutManager(layoutManager)

    // 4. Create a UITextView
    textView = UITextView(frame: newTextViewRect, textContainer: container)
    textView.delegate = self
    view.addSubview(textView)
  }

Talking head: This is quite a lot of code. Let's consider each step in turn (show slide):
o Initiate an instance of your custom text storage, and initialize it with an attributed string holding the content of the note.
o Create a layout manager.
o Create a text container and associate it with the layout manager. Then, associate the layout manager with the text storage.
o Create the actual text view with your custom text container, set the delegate, and add the text view as a subview.

Now that we understand this, our diagram that shows between the four key classes (storage, layout manager, container and text view) should make more sense (show slide):


Note that the text container has a width matching the view width, but has infinite height - or as close as CGFLOAT_MAX can come to infinity. 

In any case, this is more than enough to allow the UITextView to scroll and accommodate long passages of text.

Show Screen: 
Now still working in NoteEditorViewController.swift add the line below directly after the super.viewDidLoad() line in viewDidLoad:
createTextView()


Build and run your app; open a note and edit the text while keeping an eye on the Xcode console. You should see a flurry of log messages created as you type, as shown:
 
This is simply the logging code from within SyntaxHighlightTextStorage to give you an indication that your custom text handling code is actually being called.


Talking Head: 
The basic foundation of your text parser seems fairly solid - now to add the dynamic formatting! In this next step you are going to modify your custom text storage to embolden text *surrounded by asterisks*.
Screen: Open SyntaxHighlightTextStorage.swift and add the following method:


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


Continue showing screen: Using this code, we perform the following actions:
1 Create a bold and a normal font for formatting the text using font descriptors. Font descriptors help you avoid the use of hardcoded font strings to set font types and styles.
2 Create a regular expression (or regex) that locates any text surrounded by asterisks; for example,  here the regular expression stored in regexStr above will match and return the text "*awesome*". Don't worry if you're not totally familiar with regular expressions; they're covered in a bit more detail later.
3 Enumerate the matches returned by the regular expression and apply the bold attribute to each one.
4 Reset the text style of the character that follows the final asterisk in the matched string to "normal". This ensures that any text added after the closing asterisk is not rendered in bold type.

TH:
As a note, Font descriptors are a type of descriptor language that allows you to modify fonts by applying specific attributes, or to obtain details of font metrics, without the need to instantiate an instance of UIFont.

Coding:

Now, add the following method right after the code above:

    func performReplacementsForRange(changedRange: NSRange) {
        var extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRange(for: NSMakeRange(changedRange.location, 0)))
        extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRange(for: NSMakeRange(NSMaxRange(changedRange), 0)))
        applyStylesToRange(searchRange: extendedRange)
      }

This code expands the range that your code inspects when attempting to match your bold formatting pattern. This is required because changedRange typically indicates a single character; lineRangeForRange extends that range to the entire line of text.

Finally, add the following method right after the code we just wrote:

    override func processEditing() {
        performReplacementsForRange(changedRange: self.editedRange)
        super.processEditing()
      }

processEditing sends notifications for when the text changes to the layout manager. It also serves as a convenient home for any post-editing logic.
Talking Head: Build and run your app; type some text into a note and surround some of the text with asterisks. The text will be automagically bolded (show slide): 

That's pretty handy - you're likely thinking of all the other styles that you might add to your text. You're in luck, the next section shows you how to do just that!

TH 
The basic principle of applying styles to delimited text is rather straightforward: use a regex to find and replace the delimited string using applyStylesToRange to set the desired style of the text.

Show Screen: 
Open SyntaxHighlightTextStorage.swift and add the following method to the class:

    func createAttributesForFontStyle(style: String, withTrait trait: UIFontDescriptorSymbolicTraits) -> [NSObject : AnyObject] {
      let fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
      let descriptorWithTrait = fontDescriptor.fontDescriptorWithSymbolicTraits(trait)
      let font = UIFont(descriptor: descriptorWithTrait, size: 0)
      return [NSFontAttributeName : font]
    }

This method applies the supplied font style to the body font. It provides a zero size to the UIFont(descriptor:size:) constructor which forces UIFont to return a size that matches the user's current font size preferences.
Next, add the following property and function to the class:

    var replacements: [String : [NSObject : AnyObject]]!
    
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

Here's what's going on in this method:
o First, create a "script" style using Zapfino as the font. Font descriptors help determine the current preferred body font size, which ensures the script font also honors the users' preferred text size setting.
o Next, construct the attributes to apply to each matched style pattern. You'll cover createAttributesForFontStyle(withTrait:) in a moment; just park it for now.
o Finally, create a dictionary that maps regular expressions to the attributes declared above.

TH 
----
If you're not terribly familiar with regular expressions, the dictionary might look a bit strange. 

Talking Head: As a note, If you'd like to learn more about regular expressions above and beyond this screencast, check out this NSRegularExpression tutorial and cheat sheet.

Screen: You will also need to initialize the replacements dictionary. Add the following class initializer to the SyntaxHighlightTextStorage class:

      override init() {
        super.init()
        createHighlightPatterns()
      }
    
    Finally, replace the implementation of applyStylesToRange() with the following:
    
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

TH:
Previously, this method performed just one regex search for bold text. Now it does the same thing, but it iterates over the dictionary of regex matches and attributes since there are many text styles to look for. For each regex, it runs the search and applies the specified style to the matched pattern.

Note that the initialization of the NSRegularExpression can fail, so here it is implicitly unwrapped. If, for some reason, the pattern has an error in it resulting in a failed compilation of the pattern, the code will fail on this line, forcing you to fix the pattern, rather than failing further down.

Build and run your app, and exercise all of the new styles available to you (show slide)

We're almost done. there are just a few loose ends to clean up.
If you've changed the orientation of your screen while working on your app, you've already noticed that the app no longer responds to content size changed notifications since your custom implementation doesn't yet support this action.

As for the second issue, if you add a lot of text to a note you'll notice that the bottom of the text view is partially obscured by the keyboard; it's a little hard to type things when you can't see what you're typing!

Time to fix up those two issues.

Screen: 
To correct the issue with dynamic type, your code should update the fonts used by the attributed string containing the text of the note when the content size change notification occurs.

Add the following function to the SyntaxHighlightTextStorage class:

    func update() {
        // update the highlight patterns
        createHighlightPatterns()
    
        // change the 'global' font
        
        let bodyFont = [NSAttributedStringKey.font : UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        addAttributes(bodyFont, range: NSMakeRange(0, length))
    
        // re-apply the regex matches
        applyStylesToRange(searchRange: NSMakeRange(0, length))

The method above updates all the fonts associated with the various regular expressions, applies the body text style to the entire string, and then re-applies the highlighting styles.
Finally, open NoteEditorViewController.swift and modify 

    @objc func preferredContentSizeChanged(notification: NSNotification) {
        textStorage.update()
        updateTimeIndicatorFrame()
      }

 
TH 
Hopefully, this Text Kit screencast has helped you understand the various new features such as dynamic type, font descriptors and letterpress, that you will no doubt find use for in practically ever app you write.
