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
import SocketIO

class ViewController: UIViewController {
    private var oauthswift: OAuth2Swift?
    private var tableView:UITableView!
    private var activitesArray = [StravaActivityStruct]()
    private var accessToken:String = ""
    
    private var manager:SocketManager!
    private var socket:SocketIOClient!
    
    override func viewDidLoad() -> Void
    {
        super.viewDidLoad()
        self.setTable();
          self.setSocket();
        if let token = UserDefaults.standard.string(forKey: "token"){
            self.accessToken = token
            self.callStravaActivitesAPI()
        }
        self.setNav();
    };
    
    private func setNav() {
        title = "Strava Activities";
        let authenticateButton =  UIBarButtonItem(title: "oAuth", style: .plain, target: self, action: #selector(openAuth))
        navigationItem.rightBarButtonItems = [authenticateButton]
    };
    
    @objc private func openAuth (_ sender : UIButton) {
        self.authenticateStrava()
        NotificationCenter.default.addObserver(forName:NSNotification.Name(rawValue: "callActivities"), object:nil, queue:nil, using:callActivities)
    }
   
    private func callActivities (notification:Notification) {  self.callStravaActivitesAPI();
        self.setSocket()
    }
    
    private func setSocket() {
        manager = SocketManager(socketURL: URL(string: "http://52.32.131.208:8080")!,config: [.log(true),.connectParams(["token": "21222"])])
        socket = manager.defaultSocket
        setSocketEvents()
        socket.connect()
    };
    
    private func setSocketEvents() {
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        };
        
        socket.on("activitiesUpdated") {data, ack in
          self.callStravaActivitesAPI()
        };
    };

    private func callStravaActivitesAPI() -> Void {
        activitesArray = []; // empty array
        
        guard let url = URL(string: "https://www.strava.com/api/v3/athlete/activities") else { return }
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let access_token = self.accessToken
        request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard data != nil else { return }
            do {
                //Decode retrived data with JSONDecoder
                let decoded = try JSONDecoder().decode([StravaActivityStruct].self, from: data!)
                for item in decoded {self.activitesArray.append(item)}
               
                //reload table with new data
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    };
    
    private func authenticateStrava() {
        //Oauth2
         self.oauthswift = OAuth2Swift(
         consumerKey:    "21222",
         consumerSecret: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
         authorizeUrl:   "https://www.strava.com/oauth/authorize",
         accessTokenUrl: "https://www.strava.com/oauth/token",
         responseType:   "code"
         )
         
         self.oauthswift?.authorizeURLHandler = WebViewController();
        _ = self.oauthswift?.authorize(
         withCallbackURL: URL(string: "com.materialcause.strava://52.32.131.208")!,
         scope: "view_private,write", state:"123",
         success: { credential, response, parameters in
         print(credential.oauthToken)
         UserDefaults.standard.set(credential.oauthToken, forKey: "token")
         self.accessToken = credential.oauthToken;
         self.callStravaActivitesAPI(); // refresh table
         print ((parameters["athlete"]! as AnyObject)["id"]!!)
         },
         failure: { error in
         print(error.localizedDescription)
         }
         )
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
        return self.activitesArray.count
    };
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ActivityCell = (tableView.dequeueReusableCell(withIdentifier: "activitycell")as?ActivityCell)!
        let convertedStartDate:String = Utils.convertStravaDate(stravaDate: activitesArray[indexPath.row].startDate)
        let convertedDistance:String = Utils.metersToMiles(distance: activitesArray[indexPath.row].distance)
        let activityType:String = self.activitesArray[indexPath.row].name
        
        cell.setCell(startDate: convertedStartDate + "   |   " + activityType, distance:convertedDistance)
        
        return cell
    }
}

