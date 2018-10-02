
# Screencast Metadata

-----

### Language, Editor and Platform versions used in these screencasts:

**Language:** Swift 4.2
**Platform:** iOS 12.
**Editor**: Xcode 10.0

-----

### RW Screencast Title:
Getting Started with TextKit

### Course Description:
Learn how to easily layout your text in iOS using Swift and Text Kit

TH - Intro
--------

Hi everybody, this is Spiro, back with another screencast. Today we're going to explore how to enhance text areas by adding fonts, styles, colors... you name it. While this might sound trivial, text formatting wasn't so easy prior to iOS 7.

In early versions of iOS, webviews were the way to go when you needed to render text with mixed styling.  The release of iOS 7 brought some of the most significant text rendering changes that iOS had ever seen in what we now know as: Text Kit. All text-based UIKit controls, (apart from UIWebView), use Text Kit 

(show diagram while speaking)

In this screencast, we'll explore the various features of Text Kit using a note-taking app that features on-the-fly text styling, re-flowing text and dynamic-text resizing.

Before we get started, I wanted to give a special thanks to Colin Eberhardt and Gabriel Hauber -- this screencast is based off their original TextKit tutorial. Alright, let's jump in!


Demo
--------
I'm going to open the starter project inside XCode, and build and run the app. 

The app creates an initial array of Note instances and renders them in a table view controller. Storyboards and segues detect cell selection in the table view and transition to the view controller where users can edit the selected note.
This is a good place to look through first to get an idea of some  --- ***


As we start digging into TextKit, a good place to start is to get an understanding of Dynamic Type. 
iOS offers the option to enhance the legibility of text by increasing font weight and setting the preferred font size for apps. This feature is known as Dynamic Type and places the onus on your app to conform to user-selected font sizes and weights.

I'll show you how that works. 

Inside iOS, I'll open the Settings app and navigate to General ▸ Accessibility ▸ Larger Text to access Dynamic Type text sizes.

To make use of dynamic type, the app needs to specify fonts using styles rather than explicitly stating the font name and size. I use preferredFont(forTextStyle:) on UIFont to create a font for the given style using the user’s font preferences. There are six different font styles:   


SHOWING DIAGRAM
The text on the left uses the smallest user selectable text size. The text in the center uses the largest, and the text on the right shows the effect of enabling the accessibility bold text feature.


TH
------------
Now, let's talk about Basic Support. Implementing Basic Support for Dynamic Text is relatively straightforward. Rather than using explicit fonts within your application, you instead request a font for a specific style. At runtime the app selects a suitable font based on the given style and the user's text preferences. What's great with this, is that default labels in table views support Dynamic Type automatically! This makes life a whole lot easier.

DEMO
------------
I'll open my Storyboard to find out why. Inside the NotesListViewController,  selecting the Title label in the prototype cell. This font is HeadLine. Since it’s a Dynamic Type, the system resizes it according to the user preferences.

If I click on a note and see the Detail View, you’ll also notice that the notes do not reflect changes to the text size settings. You’ll fix that now.
Open NoteEditorViewController.swift and add the following to the end of viewDidLoad():
textView.font = .preferredFont(forTextStyle: .body)

Notice that you’re I'm specifying an exact font such as Helvetica Neue. Instead, I'm asking for an appropriate font for body text style using the .body constant.
Build and run the app again. The text view now honors the system text size. You can see the difference between the two.


TALKING HEAD
------------
That looks pretty good, but there is one issue. Changing the text size again under Settings ▸ General ▸ Accessibility ▸ Larger Text. Switch back to the app — without re-launching it — and you’ll notice that the note didn’t change the text size.

OK -- Now, it’s time to give a new style to your app!

We're going to implement a really need Letterpress effect.

The letterpress effect adds subtle shading and highlights that give text a sense of depth — kind of like the text has been slightly pressed into the screen. To get that effect, I'm going to use NSAttributedString.

DEMO
------------
 NotesListViewController.swift and replace tableView(_ tableView:, :cellForRowAtIndexPath:) with the following implementation:


 This code creates an attributed string with a HeadLine style font, blue color and a letterpress text effect, and then assigns it to the text label in the cell.
Build and run your app. Now, the table view displays the text with a nice letterpress effect


Another commonly needed styling feature is flowing text around images and other objects. Text Kit allows you to render text around complex paths and shapes with something called Exclusion Paths.

To give you a better idea of how this works, consider the common scenerio in the start app. Wouldn't it be handy to show the note’s creation date? I'm going to add a small curved view to the top right-hand corner of the note that shows this information. This view is already implemented for in the starter project inside  TimeIndicatorView.swift.

I’ll start by adding the view itself. Then I’ll create an exclusion path to make the text wrap around it.

DEMO
----------------
Open NoteEditorViewController.swift and add the following property declaration for the time indicator subview to the class:
var timeView: TimeIndicatorView!

Next, add this code to the very end of viewDidLoad():
timeView = TimeIndicatorView(date: note.timestamp)
textView.addSubview(timeView)

This creates an instance of the new view and adds it as a subview.
TimeIndicatorView calculates its own size, but it won’t automatically do this. You need a mechanism to change its size when the view controller lays out the subviews.
To do that, add the following two methods to the class:
override func viewDidLayoutSubviews() {
  updateTimeIndicatorFrame()
}
  
func updateTimeIndicatorFrame() {
  timeView.updateSize()
  timeView.frame = timeView.frame
    .offsetBy(dx: textView.frame.width - timeView.frame.width, dy: 0)
}

The system calls viewDidLayoutSubviews() when the view dimensions change. When that happens, you call updateTimeIndicatorFrame(), which then invokes updateSize() to set the size of the subview and place it in the top right corner of the text view.
Build and run. Tapping on a list item, the time indicator view will display in the top right-hand corner of the item view.


Modifying the Text Size preferences, and the view will adjust to fit.
Hmm something doesn’t look quite right. The text of the note renders behind the time indicator instead of flowing around it. This is the problem that exclusion paths solve.


OK now I'll Adding Exclusion Paths
Open TimeIndicatorView.swift and take look at curvePathWithOrigin(_:). The time indicator view uses this code when filling its background. You can also use it to determine the path around which you’ll flow your text. That’s why the calculation of the Bezier curve is broken out into its own method.
Open NoteEditorViewController.swift and add the following code to the very end of updateTimeIndicatorFrame():
let exclusionPath = timeView.curvePathWithOrigin(timeView.center)
textView.textContainer.exclusionPaths = [exclusionPath]

This code creates an exclusion path based on the Bezier path in your time indicator view, but with an origin and coordinates relative to the text view.
Build and run your project. Now, select an item from the list. The text now flows around the time indicator view.

This example only scratches the surface of the capabilities of exclusion paths. Notice that the exclusionPaths property expects an array of paths, meaning each container can support multiple exclusion paths. Exclusion paths can be as simple or as complicated as you want. Need to render text in the shape of a star or a butterfly? As long as you can define the path, exclusion paths will handle it without problem.

As you can see TextKit is quite robust -- But, we've only begun to scratch the surface.
Hmmm... we've seen that Text Kit can dynamically adjust fonts based on the user’s text size preferences. Wouldn’t it be cool if fonts could update based on the text itself? we'll save that for next time.
