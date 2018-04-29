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
import SystemConfiguration

class ViewController: UIViewController {
  private let reachability = SCNetworkReachabilityCreateWithName(nil, "www.raywenderlich.com")
  //private let reachability = Reachability()!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    displayReachableAlert()
    //setReachabilityNotifier()
  }
  
  private func displayReachableAlert() {
    var flags = SCNetworkReachabilityFlags()
    SCNetworkReachabilityGetFlags(reachability!, &flags)
    
    if (isNetworkReachable(with: flags)) {
      print(flags)
      if flags.contains(.isWWAN) {
        alert(message: "via cellular",title: "Reachable")
      } else {
        alert(message: "via WiFi",title: "Reachable")
      }
    } else if (!isNetworkReachable(with: flags)) {
      print(flags)
      alert(message: "Sorry, no connection",title: "unreachable")
    }
  }
  
  private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
    let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
    return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
  }
  
  /*
  private func setReachabilityNotifier () {
    //declare this inside of viewWillAppear
   
    NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    do {
      try reachability.startNotifier()
    } catch {
      print("could not start reachability notifier")
    }
  }
  */
  
  /*
  @objc func reachabilityChanged(note: Notification) {
    let reachabilityNotification = note.object as! Reachability
   
    switch reachabilityNotification.connection {
    case .wifi:
      print("Reachable via WiFi")
    case .cellular:
      print("Reachable via Cellular")
    case .none:
      print("Network not reachable")
    }
  }
 */
}

// MARK: - UIViewController Alert Configuration
extension UIViewController {
  func alert(message: String, title: String = "") {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(OKAction)
    
    DispatchQueue.main.async  {
      self.present(alertController, animated: true, completion: nil)
    }
  }
}
