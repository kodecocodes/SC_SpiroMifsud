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

class NoteEditorViewController: UIViewController, UITextViewDelegate {

  var textView: UITextView!
  var textStorage: SyntaxHighlightTextStorage!

  var note: Note!
  var timeView: TimeIndicatorView!

  override func viewDidLoad() {
    super.viewDidLoad()

    createTextView()
    textView.isScrollEnabled = true

    NotificationCenter.default.addObserver(self,
      selector: #selector(preferredContentSizeChanged),
      name: NSNotification.Name.UIContentSizeCategoryDidChange,
      object: nil)

    timeView = TimeIndicatorView(date: note.timestamp)
    textView.addSubview(timeView)

    NotificationCenter.default.addObserver(self, selector:  #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
  }

    @objc func preferredContentSizeChanged(notification: NSNotification) {
    textStorage.update()
    updateTimeIndicatorFrame()
  }

    func textViewDidEndEditing(_ textView: UITextView) {
    note.contents = textView.text
  }

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

  func updateTextViewSizeForKeyboardHeight(keyboardHeight: CGFloat) {
    textView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - keyboardHeight)
  }

    @objc func keyboardDidShow(notification: NSNotification) {
    if let rectValue = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
      let keyboardSize = rectValue.cgRectValue.size
        updateTextViewSizeForKeyboardHeight(keyboardHeight: keyboardSize.height)
    }
  }

    @objc func keyboardDidHide(notification: NSNotification) {
        updateTextViewSizeForKeyboardHeight(keyboardHeight: 0)
  }
}
