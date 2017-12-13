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
import OAuthSwift
class ViewController: UIViewController {
    private var oauthswift: OAuth2Swift?
    private var tableView:UITableView!
    private var activitesArray = [StravaActivityStruct]()
    private var accessToken:String = ""
    
    
    override func viewDidLoad() -> Void
    {
        super.viewDidLoad()
        self.setTable();
        self.setNav();
        if let token = UserDefaults.standard.string(forKey: "token"){
            self.accessToken = token
            
            setNavLogoutButton();
        }
        
        else
        {
            setNavAuthenticateButton();
        }
    };
    
    
    private func setNav() {
        title = "Strava Activities";
    };
    
    private func setNavLogoutButton()
    {
        let authenticateButton =  UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItems = [authenticateButton]
    }
    
    private func setNavAuthenticateButton()
    {
        let logoutButton =  UIBarButtonItem(title: "oAuth", style: .plain, target: self, action: #selector(openAuth))
        navigationItem.rightBarButtonItems = [logoutButton]
    }
    
    @objc private func openAuth (_ sender : UIButton) {
     
        NotificationCenter.default.addObserver(forName:NSNotification.Name(rawValue: "callActivities"), object:nil, queue:nil, using:callActivities)
    }
    
    @objc private func logout (_ sender : UIButton) {
        setNavAuthenticateButton()
        UserDefaults.standard.set(nil, forKey: "token")
        activitesArray = []; // empty array
        tableView.reloadData()
    }
   
    private func callActivities (notification:Notification) {
       
    }
    
}

// TableViewController

extension ViewController : UITableViewDelegate,UITableViewDataSource
{
    private func setTable() {
        let displayWidth: CGFloat = view.frame.width
        let displayHeight: CGFloat = view.frame.height
        
        tableView = UITableView(frame: CGRect(x: 0, y:0, width: displayWidth, height: displayHeight))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell");
        tableView.register(ActivityCell.self, forCellReuseIdentifier: "activitycell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(self.tableView)
    };
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    };
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ActivityCell = (tableView.dequeueReusableCell(withIdentifier: "activitycell")as?ActivityCell)!
      
        
        return cell
    }
}

