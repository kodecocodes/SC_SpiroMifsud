/// Copyright (c) 2017 Razeware LLC
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

class ActivityCell:UITableViewCell
{
    let screenSize: CGRect = UIScreen.main.bounds
    let textFont:String = "Avenir-Roman"
    let activityTextColor:UIColor = UIColor(red: 90.0/255.0, green: 90.0/255.0, blue:90.0/255.0, alpha: 1.0)
    
    var detailLabel: UILabel!
    var distanceLabel: UILabel!
    
    public func setCell(startDate:String,distance:String)  {
        selectionStyle = UITableViewCellSelectionStyle.none
        setDetailLabel(labelText :startDate)
        setDistanceLabel(labelText: distance)
    };
   
    private func setDetailLabel(labelText:String){
        detailLabel = UILabel(frame: CGRect(x:10, y:2, width:screenSize.width, height:21))
        detailLabel.text = labelText
        detailLabel.font = UIFont(name: textFont, size: 12)
        detailLabel.textColor = activityTextColor
        addSubview(detailLabel)
    }
    
    private func setDistanceLabel(labelText:String){
        distanceLabel = UILabel(frame: CGRect(x:10, y:20, width:screenSize.width, height:21))
        distanceLabel.text = labelText
        distanceLabel.font = UIFont(name: self.textFont, size: 16)
        distanceLabel.textColor = activityTextColor
        addSubview(distanceLabel)
    }
    
    override func prepareForReuse() {
        detailLabel.text = ""
        distanceLabel.text = ""
        super.prepareForReuse()
    }
}

