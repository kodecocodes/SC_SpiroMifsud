# Screencast Metadata

-----

### Language, Editor and Platform versions used in these screencasts:

**Language:** Swift 4
**Platform:** iOS 11, NodeJS
**Editor**: Xcode 9.1

-----

### RW Screencast Title:
Accessing data using Webhooks

### Course Description:
Using Webhooks to access data from a popular site such as Strava inside an iOS application

TH
------------
Hi everybody, this is Spiro. Today we’re going to explore how to use webhooks to automate data integration from a third party service into an iOS application - pretty cool! 

In my last screencast, we learned how to use oAuth to integrate third party data into an iOS application. We will now pick up and walk through how to automate that integration process using webhooks and Socket.IO. Also, we'll continue to use Strava, a popular athlete data tracking service, as our data source. 
 
 
So let’s get started!

TH
------------
Using oAuth, we can now access data from Strava. But, instead of us continually accessing the API every few minutes to check for new data, wouldn’t it be nice to have Strava notify us automatically--specifically, every time a new activity is available so we can update our table? That’s where webhooks come in. Essentially, the webhook is a callback from the Strava server. Kind of like a push notification gets sent without your app having to initiate the request. We’ll set up a webhook subscription with Strava and have their server notify us when a change takes place. 

In this example, we’ll set up a simple server to receive the events and then notify our app. To achieve this we’ll also leverage Socket.IO which give us an asynchronous connection between our server and the app.

One thing to note --  for many services, including Strava, you’ll need to enable webhooks. For Strava, you will need to let the developers know via email you’d like to your app to have webhooks activated.

Assuming you now have webhooks activated on the Strava end -- it’s time to dig in... 

TH
------------
Our first step is to set up the simple server. We’ll be using NodeJS, which we can run locally. To set that up you’ll need to run a few steps on your Mac. 

CODING
------------
[stepping through the app.js file as it’s on the screen]

Looking inside our server file, app.js. You’ll notice a basic API already set up called ‘strava-subscriptions’. 
This function is actually a verification function we’ll use to send back a unique string to confirm our server is working after we subscribe our app to the webhook. In this case, the name of the string is called hub-challenge. Basically, we’ll get that string and simply send it right back.

The POST part of the strava-subscriptions API is the actual function that the Strava webhook will hit when an activity is added. It will then emit a socket event to our app that our event handler is waiting for, and then call the Strava API to fetch more data.

CODING
------------
From Mac Terminal we'll Install NodeJS and its package manager.

Let's navigate to the project server files, and move those into a directory locally,  and install the node and the dependencies.

    brew install node

Then the dependencies. 

    npm install

Finally, let’s start the server.

    node app.js

TH
------------
Because we’re running the server on our local machine, we’ll need to route the connection to an actual URL that the Strava server can hit.  We’ll use the popular service ngrok to create a tunnel that can be accessed from the Internet. You can bypass this step if you are using a NodeJS server that is connected to the public Internet. 

On Screen
------------
You'll want to download the ngrok app for your Mac, install, and tunnel your app

$ ./ngrok http 3000

Also, we want our app to be ready to receive notifications as they pass through from Strava, to our Server, and then our app. Again, we don’t want to continuously poll a server, so we’ll be using Socket.IO to capture that event. 

CODING
--------------------
Back to our app. 

Let’s go ahead and initialize Sockets.

we'll import the library at the top of the class

    import SocketIO

then we'll declare class variables for SocketIO

    private var manager:SocketManager!
    private var socket:SocketIOClient!

Next, we'll add that event handler. After we receive the notification a Strava activity has been added, our server will emit an event. The app will then call the function we made earlier and call the API, then refresh our tableView.

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
              self.callStravaActivitiesAPI()
            }
        }

We'll also need to call setSocket after we authenticate to make sure we enable our socket connection initially.

The project class contains a stubbed out function receiving an event from our web view. Put the code in there:

    self.setSocket()

Our last step will be to subscribe our app to the enabled webhook. We’ll do that using the command they’ve given us. Remember, if we’re tunneling the webhook to our local machine, we’ll need to provide Strava with that ngrok URL, not our local IP address. 

CODING
------------
[show the code side-by-side the Strava API documentation that shows the command)

Opening your Mac Terminal. Typing in the following. Using the https version of your ngrok string:

    curl -X POST https://api.strava.com/api/v3/push_subscriptions -F client_id=21222  -F client_secret=a8e528f08245c358ebaef69f64af65dede3486b0  -F 'object_type=activity'  -F 'aspect_type=create'  -F 'callback_url=https://c9c9b792.ngrok.io/strava-subscriptions' -F 'verify_token=strava' 

You should receive a confirmation message. Success! Now let’s test our webhook.

[show app open and Strava web site. Add an activity and watch the app update]
Voila! We now have an app that can access the Strava API via oAuth and receive webhook updates! 

TH - Conclusion
------------
Thanks for watching! I’d like to thank Divyendu Singh for acting as tech editor--Be sure to follow him on Strava. Also, speaking of webhooks...How does Captain Hook communicate with other pirates?  Using an Ayyyyyyyye Phone!  Until next time, thanks for tuning in!
