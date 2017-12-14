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
Using OAuth to access data from a popular site such as Strava inside an iOS application

TH - Intro
------------
Hi everybody, this is Spiro. Today we’re going to explore integrating third party data via an API by way of OAuth, specifically OAuth2.

In this screencast, we'll leverage the popular fitness service Strava and use their API to retrieve a list of running activities with distance and time. And, we'll look at the Swift library OAuthSwift to help make this process a little easier.

Before we get started -- let's take look at what OAuth2 is and the role it plays with our API. 

Slide 1
------------
[diagram of OAuth flow]
OAuth2 is a token-based authorization protocol that allows apps to access user data without having to share personal information like username and password. A user will authorize an app by logging in and letting the third party service know that it's OK for our app to have access to their information. Then the server returns an access token, which is a unique string generated to identify an application and user. This token will get sent with every API call so we can access information about that specific user.

TH
------------
The main reason to use OAuth is that we won't need to store a username and password. Another use is on the server side. A third party service can authorize a token to expose only a certain set of data --  but it can also revoke access at any time. This makes it way more secure and flexible than sending user credentials back and forth.


CODING/SCREEN
------------
[show Strava website where you sign up for API access]

The first step is to register our app with Strava through their website. We'll get permission to access the Strava API from our app and get our access keys that we'll use to make requests later.

[show AppConfig.swift. Create the file and put the starter info in there side by side with Strava website]

Inside the project folder, there's a class called AppConfig where we'll catalog that information

We’ll fill in the appversion or clientID, the consumerKey, the consumerSecret, scope, and finally the URL for the API to request activity data for the user. We’ll also need to add a callback URL letting the service know where to redirect the user after permission is granted.  For now,  use your bundle identifier for the redirect parameter. In our case this is:

    'com.razeware.strava'

 and the standard local IP address 

    127.0.0.1

TH
------------
At this point, Strava can identify our app. But, while our app can access Strava's API, it's not very helpful if we don't have permission to get a specific user's information. This is the next part of OAuth, where the user will log in to let Strava know that our app is allowed to get data on their behalf. 

SLIDE 2
------------
[showing screen states with familiar login window]
You’ve probably seen this on some apps. A screen pops up asking you to login and then brings you back to your application following login.
The OAuth process goes like this:

We request access in our app. A login screen is brought via web view. The user logs in, our app is granted access to the activities information, and then we're returned to our app with the user token to make an API call.

TH
------------

[Show OAuthSwift github's page]

For this screencast, we're going to use OAuthSwift - a popular open source OAuth library, written in Swift. I've already installed OAuthSwift into my project using Cocoapods.

SLIDE 3
------------
[slide shows the login and the parameters as it's explained OAuthSwift makes this process easier]

OAuthSwift takes care of a lot of the details that happen with oAuth. We'll need to send our keys over with a few parameters, along with login credentials from the login screen we bring up. In return, we'll get theunique user token that gets sent in the redirect. OAuthSwift abstracts a lot of this back and forth by assisting with sending the parameters properly and handling the webview seamlessly in order to get that token. 


CODING
------------
Let’s get started by creating a function called authenticateStrava. We’ll use this function to bring up a webview with a Strava login and then send over the required parameters. First, we set an instance of oAuthSwift and add the information from AppConfig.swift that we’ve collected.

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
If you remember, when we registered our app with Strava, it asked for a callback URL. Basically, what happens is that oAuth will send back the token we need, but it needs to know where to send it. In iOS this is a little tricky because we don’t have a URL or webpage for Strava to send back to. So, we’ll need to configure a deeplink that will respond to the redirect. Let’s go ahead and add that.

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

Great. Now we have our tableview looking nice and full of formatted data.

TH - Conclusion
------------

There you have it! You should now be able to authenticate and authorize a third party service with oAuth2 and use a token to access an API.Before we go, I'd like to thank Divyendu Singh for acting as the tech editor for this screencast. Follow him on Twitter and Strava!

Now, if we could only get Strava to recognize coding as an official sports activity...ahh, a person can dream. 

