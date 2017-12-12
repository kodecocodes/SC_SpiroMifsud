# Screencast Metadata

-----

### Language, Editor and Platform versions used in these screencasts:

**Language:** Swift 4
**Platform:** iOS 11, Node JS
**Editor**: Xcode 9.1

-----

### RW Screencast Title:
Accessing data using oAuth and Webhooks

### Course Description:
Using oAuth and Webhooks to access data from a popular site such as Strava inside an iOS application

TH
------------
Hi everybody, this is Spiro. Today we’re going to explore integrating third party data with automatic updates using an API and webhooks-- all by way of oAuth. 

In this screencast, we’ll leverage the popular service Strava since it’s become one of the most popular third party services used to track running distance and times. And, we’ll look at two popular libraries called oAuthSwift and Socket.IO to help make this a process a little easier. 

So let’s get started!

CODING/SCREEN
------------
[show AppConfig.swift. Create the file and put the starter info in there] side by side with Strava website 

First thing we’ll need to do is get permission to access the Strava API. From the Strava.com site we'll register and app and gather a few access keys and a client ID. There’s an AppConfig.swift file in our starter project to put catalog this information.
[show strava page where you sign up. And cut and paste the keys]

We’ll fill in the appversion, the consumerKey, the consumerSecret, and finally the URL for the API to request activity data for the user. We’ll need to put add a callback URL which I’ll explain later. For now, use your bundle identifier, in our case

    'com.razeware.strava'

 and the standard local IP address 

    127.0.0.1.

TH
------------
Now that we have set up Strava for API access,  we’ll need to implement the oAuth portion  into our application. You’ve probably seen this on some apps. A screen pops up asking you to use your login and then bring you back to your application. So, why do we need oAuth anyway? Isn’t is just for login?

For our app, oAuth is going to going to act as the conduit to the data from our service. In our case, to open a gateway up so we can access their API, which will give us permission to fetch data. We’ll be using a protocol called oAuth2 that will open permissions to our app.

TH
------------
Our starter project already contains the oAuthSwift library and a tableView that we’ll use to load in the data. The library takes care of a lot of the handshaking that happens with oAuth. What we’ll be doing is sending our keys over with a few parameters, along with login credentials from the login screen we bring up. In return, we'll get a token that then will allow us to make calls on behalf of the user without having to keep their username and password --instead, we’ll use the token with our API call.

Let’s create a function called authenticateStrava. We’ll use this function to bring up a webview with a Strava login and then send over the required parameters.

CODING
------------
First, we set an instance of oAuthSwift and add our information from AppConfig.swift  we’ve collected.
Next, we create a webView with the additional parameters. 

     private func authenticateStrava() {
             self.oauthswift = OAuth2Swift(
             consumerKey:    AppConfig.consumerKey,
             consumerSecret: AppConfig.consumerSecret,
             authorizeUrl:   AppConfig.authorizeURL,
             accessTokenUrl: AppConfig.accessTokenUrl,
             responseType:   AppConfig.responseType
             )

 
Plus we’ll need to add that callback URL. 
         

    self.oauthswift?.authorizeURLHandler = WebViewController();
        _ = self.oauthswift?.authorize(
         withCallbackURL: URL(string: AppConfig.callBackURL)!,
         scope: AppConfig.scope, state: AppConfig.state,
         success: { credential, response, parameters in

TH
------------
This is standard for the oAuth2 protocol. Basically, what happens is that oAuth will send back the we need, but it needs to know where to send it. In iOS this is a little tricky because we don’t have a URL or webpage for Strava to it send back to. So, we’ll need to configure a deeplink that will respond to the redirect. Let’s go ahead and add that.

CODING
------------
Inside the info.plist we’ll add an entry called URL types. Then we’ll add a URL scheme, which will be that callback URL. Next inside our App Delegate. We’ll add a handler for when that callback occurs and let OAuthSwift know to handle that specific URL.

     func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
      
            if (url.host! == "127.0.0.1") {
              OAuthSwift.handle(url: url)
            }
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        return true
    }

CODING
------------
Going back to our ViewControlller. We’ll also store this token in the app inside UserDefaults. This is going to be the absolute most insecure way to persist this type of data. It’s really not secure -- you’d really want to use something like the keychain, but for demonstration purposes we’ll use UserDefaults.
 
     UserDefaults.standard.set(credential.oauthToken, forKey: "token")
         self.accessToken = credential.oauthToken
          
Then, we’ll change the navigation login button to a more appropriate logout function that’s already been provided.

      self.setNavLogoutButton()
         self.callStravaActivitesAPI()
         },

And, lastly we’ll want to print any errors to the console should something go wrong.
   
     failure: { error in
         print(error.localizedDescription)
         }
         )
    }
}

We’ve got a warning now that we have no function named callStravaActivitesAPI().
We’ll stub one out  for now. Create an function callStravaActivites().
And let’s print something to the console when this gets called.

    private func callStravaActivitesAPI()
    {
          print(“I’ve been called!”);
    }

Let’s run the app. Ok, so looks like it’s opening the oAuth window to authenticate and after a succesful login the app is storing the token. If we look at the console debugger we’ll see that our function callStravaActivitiesAPI is also being called. Time to put some that tableview!

We’ll create a URL request to access the Strava API and add the required parameters to the header of our request.  But after that we’ll still need to parse the JSON response into our table cell. 

TH
------------
Inside our project file,  you’ll find a struct, StravaActivityStruct, that outlines the data we’ll be collecting from the returned JSON. We’re after the date called name, distance, and start date. We’ll use the iOS11 JSONDecoder function and our struct to fill an Array with StravaActivity items. And lastly, we’ll have our tableView extract that data and put it into rows. 

Coding
------------
Back to our callStravaActivitesAPI function.

 We’ll create an empty array to fill with data for our table.
   
     activitesArray = []; 

  Next, we’ll make a URL request to the Strava API.
 
       guard let url = URL(string: AppConfig.API) else { return }
        var request = URLRequest(url: url)
     
Give the request the  proper parameters, return type, headers, and our token that Strava is looking for 
[show a side by side of the Strava documentation outlining the GET request parameters]
 
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
          
Now we’re adding the  iOS11 JSONDecoder function and our struct to fill an Array with StravaActivity items. 


let decoded = try JSONDecoder().decode([StravaActivityStruct].self, from: data!)
        for item in decoded {self.activitesArray.append(item)}
            
Reload our table once JSON has been received, parsed, and added to our data array 

      DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })

 Add some error handling.
 
     } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    };

OK let’s run it.

Looks close. Let’s format the data so it’s a little more readable. There’s a convenience class called Utils.swift inside the project with some conversion functions. Let’s apply them to the distance and date.

We’ll convert the date to a more readible format here using convertStravaDate

     let convertedStartDate:String = Utils.convertStravaDate(stravaDate: activitesArray[indexPath.row].startDate)

 
And, we’ll convert meters to miles using metersToMiles
 

     let convertedDistance:String = Utils.metersToMiles(distance: activitesArray[indexPath.row].distance)

Run again.

Great. Now we’ve got our tableview looking nice and full of data.

TH
------------
Ok, so we can access data from Strava. But, instead of us continually accessing the API every few minutes to check for new data, wouldn’t it be nice to have Strava notify us everytime a new activity is available so we can update our table? That’s where webhooks come in. We’ll set up a webhook subscription with Strava and have the Strava server let us know when a change takes place. In this next part, we’ll have to set up a simple server to receive the events and then notify our app. To achieve all this we’ll also leverage Socket.IO which give us an asynchronous connection between our server and the app.

One thing to note --  for many services you’ll need to enable webhooks. For strava, you will need to let the developers know via email you’d like to your app to have webhooks activated.

Assuming you now have webhooks activated on the Strava end -- it’s time to dig in.. 

CODING
------------
[stepping through the app.js file as it’s on the screen]

Looking inside out server file. You’ll notice a basic API already set up called ‘strava-subscriptions’. 
This function is actually a verification function we’ll use to send back a unique string to confirm our server is working after we subscribe our app to the webhook. In this case, the name of the string is called hub-challenge. Basically, we’ll get that string and simply send it right back.

The POST part of the strava-subscriptions API, is the actual function that the Strava webhook will hit when an activity is added and then emit a socket event to our app that our event handler is waiting for, and then call the Strava API to fetch more data.

TH
------------
Our first step, is to set up the simple server. We’ll be using NodeJS, which we can run locally. To set that up you’ll need to run a few steps on your mac. 

CODING
------------
Inside the app.js file you’ll see the following functions. 
From Mac Terminal we'll Install NodeJS and its package manager.

Let's navigate to the project server files, and move those into a directory locally,  and install the node and the dependencies.

    brew install node

Then the dependencies. 

    npm install

Finally, let’s start the server.

    node app.js

TH
------------
Because we’re running the server on our local machine, we’ll need to route the connection to an actual URL that the Strava server can hit.  We’ll use the popular service ngrok to create a tunnel that can be access from the Internet. You can bypass this step if you are using a NodeJS server that is connected to the public Internet. 

Also, we want our app to be ready to receive notifications as they pass through from Strava, to our Server, and then our app. Again, we don’t want to continuously poll a server, so we’ll be using Socket.IO to capture that event. 

CODING
--------------------
Back to our app. 

Let’s go ahead and initialize Sockets  add that event handler. After we receive the notification a Strava activity has been added, our server will emit an event and the app will then call  the function we made earlier and call the API , then refresh our tableView.

    private func setSocket() {
            manager = SocketManager(socketURL: URL(string: AppConfig.socketURL)!,config: [.log(true),.connectParams(["token": "21222"])])
            socket = manager.defaultSocket
            setSocketEvents()
            socket.connect()
        }
        
        private func setSocketEvents() {
            socket.on(clientEvent: .connect) {data, ack in
            }
            
            socket.on("activitiesUpdated") {data, ack in
              self.callStravaActivitesAPI()
            }
        }

we'll also need to call setSocket after we authenticate to make sure we enable our socket connection initially.

the project class contains a stubbed out function receiving an event from our web view. put the code in there:

    self.setSocket()

Our last step will be to subscribe our app to the enabled webhook. We’ll do that using the command they’ve given us. Remember, if we’re tunneling the webhook to our local machine, we’ll need to provide strava with that ngrok URL, not our local IP address. 

CODING
------------
[show the code side-by-side the Strava API documentation that shows the command)

Opening your Mac Terminal. Typing in the following. Using the https version of your ngrok string:

    curl -X POST https://api.strava.com/api/v3/push_subscriptions -F client_id=21222  -F client_secret=a8e528f08245c358ebaef69f64af65dede3486b0  -F 'object_type=activity'  -F 'aspect_type=create'  -F 'callback_url=https://c9c9b792.ngrok.io/strava-subscriptions' -F 'verify_token=strava' 

You should receive a confirmation message. Success! Now let’s test our webhook.

[show app open and strava web site. Add an activity and watch the app update]
Voila! We know have an app that access the Strava API via oAuth and receive webhook updates! 
Thanks for watching. Before you go, I’d like to thank Divyendu Singh for acting as tech editor.  Be sure to follow him on Strava!
