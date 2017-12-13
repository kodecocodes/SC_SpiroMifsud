# Screencast Metadata

-----

### Language, Editor and Platform versions used in these screencasts:

**Language:** Swift 4
**Platform:** iOS 11
**Editor**: Xcode 9.1

-----

### RW Screencast Title:
Accessing data using oAuth

### Course Description:
Using oAuth  to access data from a popular site such as Strava inside an iOS application

TH - Intro
------------
Hi everybody, this is Spiro. Today we’re going to explore using oAuth to integrate third party data into an iOS mobile app with updates using an API.
 
In this screencast, we’ll leverage a popular athlete data tracking service called Strava – this will be our source of third party data. We’ll use the library oAuthSwift to integrate the data from Strava into our own application.
 
So let’s get started!

CODING/SCREEN
------------
[show AppConfig.swift. Create the file and put the starter info in there] side by side with Strava website 

First thing we’ll need to do is get permission to access the Strava API. From the Strava.com site we'll register an app and gather a few access keys and a client ID. There’s an AppConfig.swift file in our starter project to catalog this information.
[show strava page where you sign up. And cut and paste the keys]

We’ll fill in the appversion, the consumerKey, the consumerSecret, and finally the URL for the API to request activity data for the user. We’ll need to add a callback URL-- which I’ll explain later. For now, use your bundle identifier. In our case this is:

    'com.razeware.strava'

 and the standard local IP address 

    127.0.0.1

TH
------------
Now that we have set up Strava for API access, we’ll need to implement the oAuth portion into our application. You’ve probably seen this on some apps. A screen pops up asking you to login and then brings you back to your application. So, why do we need oAuth anyway? Isn’t it just for login?

For our app, oAuth is going to going to act as the conduit for the data from our service. In our case, we will use oAuth to open a gateway up so we can access their API, which will give us permission to fetch data. We’ll be using a protocol called oAuth2 that will open permissions to our app.

TH
------------
Our starter project already contains the oAuthSwift library and a tableView that we’ll use to load in the data. The library takes care of a lot of the handshaking that happens with oAuth. What we’ll be doing is sending our keys over with a few parameters, along with login credentials from the login screen we bring up. In return, we'll get a token that then will allow us to make calls on behalf of the user without having to keep their username and password --instead, we’ll use the token with our API call.

Let’s create a function called authenticateStrava. We’ll use this function to bring up a webview with a Strava login and then send over the required parameters.

CODING
------------
First, we set an instance of oAuthSwift and add the information from AppConfig.swift that we’ve collected.

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
This is standard for the oAuth2 protocol. Basically, what happens is that oAuth will send back the token we need, but it needs to know where to send it. In iOS this is a little tricky because we don’t have a URL or webpage for Strava to send back to. So, we’ll need to configure a deeplink that will respond to the redirect. Let’s go ahead and add that.

CODING
------------
Inside info.plist we’ll add an entry called URL types. Then we’ll add a URL scheme, which will be that callback URL. Next we'll navigate our App Delegate. We’ll add a handler for when that callback occurs and let OAuthSwift know to handle that specific URL.

     func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
      
            if (url.host! == "127.0.0.1") {
              OAuthSwift.handle(url: url)
            }
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        return true
    }

CODING
------------
Going back to our ViewController. Here we'll also store this token in the app inside UserDefaults. This is not a very secure way to persist this type of data. Really, it's not secure and you’d want to use something like the keychain, but for demonstration purposes we’ll store the token in UserDefaults.
 
     UserDefaults.standard.set(credential.oauthToken, forKey: "token")
         self.accessToken = credential.oauthToken
          
Then, we’ll change the navigation login button to a more appropriate logout function that’s already been provided.

      self.setNavLogoutButton()
         self.callStravaActivitiesAPI()
         },

And, lastly we’ll want to print any errors to the console should something go wrong.
   
     failure: { error in
         print(error.localizedDescription)
         }
         )
    }
}

We’ve got a warning now that we have no function named callStravaActivitiesAPI().
We’ll stub one out for now. 

Create a function callStravaActivities().
And let’s print something to the console when this gets called.

    private func callStravaActivitiesAPI()
    {
          print(“I’ve been called!”);
    }

Let’s run the app. 

Ok, so looks like it’s opening the oAuth window to authenticate, and after a succesful login the app is storing the token. If we look at the console debugger we’ll see that our function callStravaActivitiesAPI is also being called. 

Time to put that data into the tableview!

We’ll create a URL request to access the Strava API and add the required parameters to the header of our request.  But after that, we’ll still need to parse the JSON response into our table cell. 

TH
------------
Inside our project file, you’ll find a struct, StravaActivityStruct, that outlines the data we’ll be collecting from the returned JSON. We want to collect the data called name, distance, and start date. We’ll use the iOS11 JSONDecoder function and our struct to fill an Array with StravaActivity items. And lastly, we’ll have our tableView extract that data and put it into rows. 

Coding
------------
Back to our callStravaActivitiesAPI function.

 We’ll create an empty array to fill with data for our table.
   
     activitiesArray = []; 

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
          
Now we’re adding the iOS11 JSONDecoder function and our struct to fill an Array with StravaActivity items. 

let decoded = try JSONDecoder().decode([StravaActivityStruct].self, from: data!)
        for item in decoded {self.activitiesArray.append(item)}
            
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

Next we'll move over to our tableView and set the cells to the data we've just appended to our activitiesArray.

```
let cell:ActivityCell = (tableView.dequeueReusableCell(withIdentifier: "activitycell")as?ActivityCell)!
let startDate:String = activitesArray[indexPath.row].startDate
let distance:String = activitesArray[indexPath.row].distance
let activityType:String = self.activitesArray[indexPath.row].name
cell.setCell(startDate: startDate + "   |   " + activityType, distance:distance)
```

OK let’s run it.

Looks close. Let’s format the data so it’s a little more readable. There’s a convenience class called Utils.swift inside the project with some conversion functions. Let’s apply them to the distance and date.

We’ll convert the date to a more readable format here using convertStravaDate

     let convertedStartDate:String = Utils.convertStravaDate(stravaDate: activitiesArray[indexPath.row].startDate)

 
And, we’ll convert meters to miles using metersToMiles
 

     let convertedDistance:String = Utils.metersToMiles(distance: activitiesArray[indexPath.row].distance)
      
And let's add the reformated variables to the setCell function      

     cell.setCell(startDate: convertedStartDate + "   |   " + activityType, distance:convertedDistance)


Run again.

Great. Now we have our tableview looking nice and full of formatted data, which means we've successfully used oAuth to integrate third party data from Strava into our iOS app. Phew!

TH - Conclusion
------------

Thanks for watching. Before you go, I'd like to thank Divyendu Singh for acting as tech editor. Now, if we could only get Strava to recognize coding as an official sports activity...ahh, a person can dream. 
