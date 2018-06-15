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

class NotesListViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver (self,
                                            selector: #selector(preferredContentSizeChanged),
                                            name: NSNotification.Name.UIContentSizeCategoryDidChange,
      object: nil)
  }

    override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // whenever this view controller appears, reload the table. This allows it to reflect any changes
    // made whilst editing notes
    tableView.reloadData()
  }

    @objc func preferredContentSizeChanged(notification: NSNotification) {
    tableView.reloadData()
  }

  // #pragma mark - Table view data source
    
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
    return notes.count
  }

    override func tableView(_ tableView: UITableView,
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

 func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .delete {
      notes.remove(at: indexPath.row)
       
        tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
    }
  }

  // #pragma mark - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let editorVC = segue.destination as? NoteEditorViewController {

      if "CellSelected" == segue.identifier {
        if let path = tableView.indexPathForSelectedRow {
          editorVC.note = notes[path.row]
        }
      } else if "AddNewNote" == segue.identifier {
        let note = Note(text: " ")
        editorVC.note = note
        notes.append(note)
      }
    }
  }

}
