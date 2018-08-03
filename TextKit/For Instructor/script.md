
# Screencast Metadata

-----

### Language, Editor and Platform versions used in these screencasts:

**Language:** Swift 4.1
**Platform:** iOS 11.4
**Editor**: Xcode 9.4

-----

### RW Screencast Title:
Getting Started with TextKit

### Course Description:
Learn how to easily layout your text in iOS using Swift and Text Kit

TH - Intro
------------
Hi everybody, this is Spiro, back with another screencast. Today we're going to explore how to enhance text areas by adding fonts, styles, and. While this might sound trivial, text formatting wasn't so easily prior to iOS 7. The release of iOS 7  brought some of the most significant text rendering changes that iOS had ever seen. 

Before TextKit and before even iOS 6. Webviews were the way to go when you needed to render text with mixed styling. In 2012, iOS 6 added attributed string support to UIKit controls.. making it easier to create layouts without having to resort to rendered HTML. iOS 6 introduced UIKit that based text capabilities on both Webkit and Core Graphics drawing functions. 

Slide 1
------------
[diagram of pre iOS 6 text rendering]
Attributed Strings were helpful, but for advanced layouts and multiline text, the only real solution was Core Text -- which was a bit different and low level to work with.

Fast forward to iOS 7, a new framework, TextKit, gets introduced. TextKit ...built on top of CoreText -- abstracts the power of the Core Text framework and wraps it in a nice object-oriented API.

In this screencast, we'll explore the various features of Text Kit using note-taking app for that features reflowing text, dynamic text resizing, and on-the-fly text styling.

TH
------------
Before we get started, I wanted to give a special thanks to Colin Eberhardt and Gabriel Hauber -- this screencast is based off their original TextKit tutorial.



TH
------------
In order to make use of dynamic type we'll need to specify fonts using styles rather than explicitly stating the font name and size. iOS 7 added a new method to UIFont, preferredFontForTextStyle, that creates a font for the given style using the user's font preferences.


SLIDE 2
------------
Show Slide: 
These are the different font styles

The text on the left uses the smallest user selectable text size, the text in the center uses the largest, and the text on the right shows the effect of enabling the accessibility bold text feature.

TH
------------
Now, let's talk about basic support. Implementing basic support for dynamic text is relatively straightforward. Rather than using explicit fonts within your application, you instead request a font for a specific style. At runtime the app selects a suitable font based on the given style and the user's text preferences. What's great with this is, default labels in table views support Dynamic Type automatically! This makes life a lot easier.

Show Screen
------------

Ok  Let's dig in

Code
------------
[screens of sample app]
This screencast includes a project with the user interface pre-created so we can stay focused on Text Kit. 

Let's build and run the included app and try changing the default text size to various values. You will discover that both the text size and cell height in the table view list of notes changes accordingly. And you didn't have to do a thing! But do observe also that the notes themselves do not reflect changes to the text size settings

Code 
------
Open NoteEditorViewController.swift and add the following to the end of viewDidLoad:

textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
Notice you're not specifying an exact font such as Helvetica Neue. Instead, you're asking for an appropriate font for body text with the UIFontTextStyleBody text style constant.
Next, open NotesListViewController.swift and add the following to the t

    ableView(_:cellForRowAtIndexPath:) method, just before the return call:
    cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)

TH:
Build and run the app again, and you'll notice that the table view and the note screen now honor the current text size. The difference between the two is pretty obvious 

This looks pretty good - but it's part of what we're trying to get to. 

Coding
--------
Let's head back to the Settings app under General/Text Size and modify the text size again. This time, switch back to SwiftTextKitNotepad - without re-launching the app - and you'll notice that your app didn't respond to the new text size.

TH:
--------
You might be wondering why it seems you're setting the font to the same value it had before. When the user changes their preferred font size, you must request the preferred font again; it won't update automatically. 

Show Screen: The font returned with preferredFontForTextStyle will be different when the font preferences are changed.

Now, open up NotesListViewController.swift and override the viewDidLoad function by adding the following code to the class:

      super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
          selector: #selector(preferredContentSizeChanged),
          name: NSNotification.Name.UIContentSizeCategoryDidChange,
          object: nil)

Hmm, isn't this the same code you just added to NoteEditorViewController.swift? Yup, but you'll handle the preferred font change in a slightly different manner.
Add the following method to the class:

    @objc func preferredContentSizeChanged(notification: NSNotification) {
        textStorage.update()
        updateTimeIndicatorFrame()
      }

TH:
This code simply instructs the table view to reload its visible cells, which updates the appearance of each cell. This will trigger the calls to preferredFontForTextStyle and refresh the font choice.
Now, build and run your app; change the text size setting, and verify that your app responds correctly to the new user preferences.

Great, that part seems to work well, but when you select a really small font size, your table view ends up looking a little .. off. 

Code 
-------
 
This is one of the trickier aspects of dynamic type . To ensure your application looks good across the range of font sizes, your layout needs to be responsive to the user's text settings. Auto Layout solves a lot of problems for you, but this is one problem you'll have to solve yourself.

Show Screen: Your table row height needs to change as the font size changes. Implementing the tableView(_:heightForRowAtIndexPath:) delegate method solves this quite nicely.
Add the following code to NotesListViewController.swift, in the section labelled Table view data source:

    let label: UILabel = {
        let temporaryLabel = UILabel(frame: CGRect(x: 0, y: 0, width: Int.max, height: Int.max))
        temporaryLabel.text = "test"
        return temporaryLabel
        }()
    
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
        {
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        label.sizeToFit()
        return label.frame.height * 1.7
      }
      override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
        {
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        label.sizeToFit()
        return label.frame.height * 1.7
      }

This code creates a single shared instance of UILabel which the table view uses to calculate the height of the cell. Then, in tableView(_:heightForRowAtIndexPath:) you set the label's font to be the same font used by the table view cell. It then invokes sizeToFit on the label, which forces the label's frame to fit tightly around the text, and results in a frame height proportional to the table row height.

TH:
Build and run your app. Next, modify the text size setting once more and the table rows now size dynamically to fit the text size

If you like, you may now reset the deployment to iOS 8 for the rest of the tutorial.

TH:
Now, let's talk about this really cool letterpress effect. The letterpress effect adds subtle shading and highlights to text that give it a sense of depth - much like the text has been slightly pressed into the screen.

Code:

Open NotesListViewController.swift and replace tableView(_:cellForRowAtIndexPath:) with the following implementation:

    Override func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
    
        let note = notes[indexPath.row]
            let font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        let textColor = UIColor(red: 0.175, green: 0.458, blue: 0.831, alpha: 1)
        let attributes = [
          NSAttributedStringKey.foregroundColor : textColor,
          NSAttributedStringKey.font : font,
          NSAttributedStringKey.textEffect : NSAttributedString.TextEffectStyle.letterpressStyle as NSString
        ]
        let attributedString = NSAttributedString(string: note.title, attributes: attributes)
    
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
    
        cell.textLabel?.attributedText = attributedString
        
        return cell
      }

This code creates an attributed string for the title of a table cell using letterpress style.

Build and run your app; your table view will show the text with a nice letterpress effect (show slide): 

TH
-----------
Now what else can we do? We can use exclusion paths to render text around complex paths and shapes.

It would be handy to tell the user the note's creation date; you're going to add a small curved view to the top right-hand corner of the note that shows this information.

You'll start by adding the view itself - then you'll create an exclusion path to make the text wrap around it.

Show screen: adding the View
Open up NoteEditorViewController.swift and add the following property declaration to the class:

    var timeView: TimeIndicatorView!

As the name suggests, this houses the time indicator subview.
Next, add this code to the very end of viewDidLoad:

    timeView = TimeIndicatorView(date: note.timestamp)
        textView.addSubview(timeView) 

This simply creates an instance of the new view and adds it as a subview.
TimeIndicatorView calculates its own size, but it won't do this automatically. You need a mechanism to call updateSize when the view controller lays out the subviews.
Finally, add the following two methods to the class:

    override func viewDidLayoutSubviews() {
        updateTimeIndicatorFrame()
        textView.frame = view.bounds
      }
    
    func updateTimeIndicatorFrame() {
        timeView.updateSize()
      
        timeView.frame = timeView.frame.offsetBy(dx: textView.frame.width - timeView.frame.width, dy: 0)
    
        let exclusionPath = timeView.curvePathWithOrigin(origin: timeView.center)
        textView.textContainer.exclusionPaths = [exclusionPath]
      } 

viewDidLayoutSubviews calls updateTimeIndicatorFrame, which does two things: it calls updateSize to set the size of the subview, and positions the subview in the top right corner of the text view.
All that's left is to call updateTimeIndicatorFrame when your view controller receives a notification that the size of the content has changed. Replace the implementation of preferredContentSizeChanged to the following:


@objc func preferredContentSizeChanged(notification: NSNotification) {
    textStorage.update()
    updateTimeIndicatorFrame()
  }


Build and run your project; tap on a list item and the time indicator view will display in the top right hand corner of the item view, (show screen):

Modify the device Text Size preferences, and the view will automatically adjust to fit.
However, something doesn't look quite right. The text of the note renders behind the time indicator view instead of flowing neatly around it. Fortunately, this is the exact problem that exclusion paths are designed to solve.

Open TimeIndicatorView.swift and take a look at curvePathWithOrigin(). The time indicator view uses this code when filling its background, but you can also use it to determine the path around which you'll flow your text. Aha - that's why the calculation of the Bezier curve is broken out into its own method!

TH
--------
All that's left is to define the exclusion path itself. Open up NoteEditorViewController.swift and add the following code block to the very end of updateTimeIndicatorFrame:


let exclusionPath = timeView.curvePathWithOrigin(origin: timeView.center)
    textView.textContainer.exclusionPaths = [exclusionPath]

The above code creates an exclusion path based on the Bezier path created in your time indicator view, but with an origin and coordinates that are relative to the text view.

TH
Build and run your project and select an item from the list; the text now flows nicely around the time indicator view.

This simple example only scratches the surface of the abilities of exclusion paths. You might notice that the exclusionPaths property expects an array of paths, meaning each container can support more than one exclusion path.

Exclusion paths can be as simple or as complicated as you want. Need to render text in the shape of a star or a butterfly? As long as you can define the path, exclusionPaths will handle it without problem!

As the text container notifies the layout manager when an exclusion path changes, you can implement dynamic or even animated exclusions paths - just don't expect your user to appreciate the text moving around on the screen as they're trying to read!

(show slide)
You've seen that Text Kit can dynamically adjust fonts based on the user's text size preferences. But wouldn't it be cool if fonts could update dynamically based on the actual text itself? What if you want to make this app automatically:
o   Make any text surrounded by the tilde character (~) a fancy font
o   Make any text surrounded by the underscore character (_) italic
o   Make any text surrounded by the dash character (-) crossed out
o   Make any text in all caps colored red

TH
-----
That's exactly what we'll do by leveraging the power of the Text Kit framework!
To do this, you'll need to understand how the text storage system in Text Kit works. Here's look at how"Text Kit stack" is used to store, render and display text 

Behind the scenes, Apple creates these classes for you automatically when you create a UITextView, UILabel or UITextField. In your apps, you can either use these default implementations or customize any part to get your own behavior…but we'll save that for next time.



