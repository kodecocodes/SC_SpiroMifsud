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

TH - Intro
------------
Hi everybody this is Spiro. Today we're going to explore webhooks and how they can be used inside an app. If you caught my last screencast on OAuth, I talked about how we can use OAuth to authenticate a user and then make a call to a third party API. In this screencast, I'll pick up from where I left off and show how we can use webhooks to enhance the process of fetching data from an API.

So before we dive in. Let's take a look at what a webhook is --  and why we'd want to use one. 

SLIDE 1
------------
[slide shows the flow of the previous project app on oAuth]

In the last project app, we authenticated a user with the fitness service Strava using OAuth. Then we added some code to call Strava's API and received a list of activities for the authenticated user. 

It worked well. When we wanted a list of the user activities we'd make a call to the API to retrieve the latest list. 

The only problem is we never actually knew when to look for new data. There was no guarentee that the requests we were making would actually turn up something new. Essentially, we'd have to keep hitting the API, and hitting it,  and hitting it until we got lucky.... 

And that seems pretty inefficient.

Now you're probably thinking... wouldn't it be nice if Strava would just let us know when there were new activities? That way we'd be certain that our request would bring us new data. Well, that's where webhooks come in!

SLIDE 2
------------
[Slide shows API process. request / receive and the web hook process: data changing --> Strava server notified --> and hitting a URL]

A webhook is essentially web callback service.  A webhook will automatically send data to applications as it changes.

In an API, we make a request and then receive the data. In our project app, we call getActivites and make a URLRequest to the Strava server. The Strava server then returns the activities data.

The webhook on the other hand notifies us whenever there's a change. That way we can then call the API knowing there's updated data.

This eliminates the scenario where have to keep hitting the API in order to get the latest information. 

To do this, we'll need to subscribe our app to the web hook service and provide the Strava server with a URL to send the notification to.

TH
------------
One thing to keep in mind is we're not replacing the API. 
We're still going to call it. The webhook will notify us there's a change so we can do whatever it is we need to do. In this case, we'll fetch the list of activities by calling the API.

Sounds great. But where to? 
Webhooks need an endpoint URL for its callback.  Just like we're calling an API that's hitting the Strava server, the Strava webhook needs something to hit as well. It won't know to ping our phone, so we'll need to set up a server as an endpoint for the webhook. 

We'll also need to set up something called Socket.IO on our server and on our client.

SLIDE 3
------------
[slide shows diagram of socket event emitting from server to app]

Socket.IO is a library that will let us send 2 way communication in real time from a server to a client. Using the socket.IO client library in our app, we're able to receive emitted events from our server. When we implement Socket.IO, we'll create an open connection to the server. 

SLIDE 4
------------
[slide shows diagram of entire process and illustration of app, simple server with sockets, and Strava server with directional arrows]

So when a new activity gets recorded in Strava, it will work like this.

Our app will have an open socket connection to our simple server. This will always be on.
When a new activity is recorded in Strava. Strava's webhook will notify our simple server. Our simple server will then notify our app by way of Socket.io. And finally, knowing that there are new activities, we'll make a call to the API.

TH
------------
One thing to note before we get started. For many services, including Strava, you may need to enable webhooks prior to using them. For Strava, you will need to let the developers know via email you’d like to your app to have webhooks activated.

I've already emailed Strava and they've enabled webhooks for my app, so let's dig in.

TH
------------
Our first step is to set up the simple server that will receive web hook events from Strava and emit events to our app using Socket.IO. We’ll be using NodeJS, which we can run locally. 

To set that up you’ll need to run a few steps on your Mac. Inside the project files, there is a folder labeled 'server'.  We'll be using the file app.js.

CODING
------------
[stepping through the app.js file as it’s on the screen]

Looking inside our server file, app.js. You’ll notice a basic API already set up called ‘strava-subscriptions’. 

This function is actually a verification function we’ll use to send back a unique string to confirm our server is working after we subscribe our app to the webhook. In this case, the name of the string is called hub-challenge.  We’ll get that string and simply send it right back.

The POST part of the strava-subscriptions API is the actual function that the Strava webhook will hit when an activity is added. It will then emit a socket event to our app that our event handler is waiting for, and then call the Strava API to fetch more data.

CODING
------------
From Mac Terminal we'll Install NodeJS and its package manager.

Let's navigate to the project server files, and move those into a local directory on your machine,  and install the node and the dependencies.

    brew install node

Then the dependencies. 

    npm install

Finally, start the server.

    node app.js

TH
------------
Because we’re running the server on our local machine, we’ll need to route the connection to an actual URL that the Strava server can hit.  Remember the webhook needs a publicly accessible URL for its callback. To do this we’ll use the popular service ngrok to create a tunnel that can be accessed from the Internet. 

Slide 5 & Slide 6
------------
[show both slides]

ngrok is a free tool that enables us to create a tunnel from a public URL to our application running locally.
The tool will create a publicly accessible URL that will route directly to your computer. Your local machine's server becomes accessible and ngrok generates links like this.

You can bypass this next step if you are using a NodeJS server that is connected to the public Internet. 

On Screen
------------
If you are running the server on your local machine, you'll want to download the ngrok app for your Mac, install, and tunnel your app

    $ ./ngrok http 3000

Also, we want our app to be ready to receive notifications as they pass through from Strava, to our Server, and then our app. Again, we don’t want to continuously poll a server, so we’ll be using Socket.IO to capture that event. 

CODING
--------------------
You can find the socket.io iOS library at https://github.com/socketio/socket.io-client-swift.
I've preinstalled library via CocoaPods, or you can copy the files from GitHub into your project.
[show GitHub screen and then CocoaPods screen]

Back to our app. Let’s go ahead and initialize Sockets.

We'll import the library at the top of the class

    import SocketIO

Then we'll declare class variables for SocketIO

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

Opening your Mac Terminal. Type in the following using the https version of your ngrok string:

    curl -X POST https://api.strava.com/api/v3/push_subscriptions -F client_id=21222  -F client_secret=a8e528f08245c358ebaef69f64af65dede3486b0  -F 'object_type=activity'  -F 'aspect_type=create'  -F 'callback_url=https://c9c9b792.ngrok.io/strava-subscriptions' -F 'verify_token=strava' 

You should receive a confirmation message. Success! Now let’s test our webhook.

[show app open and Strava web site. Add an activity and watch the app update]

Voila! We now have an app that can access the Strava API via oAuth and receive webhook updates! 

TH - Conclusion
------------
At this point, you should understand how to use webhooks to receive notifications of events from a web app, such as when data is updated. Before we go, I would like to thank Divyendu Singh for acting as the tech editor for this screencast. Follow him on Twitter and Strava!

Also, speaking of webhooks...How does Captain Hook communicate with other pirates?  Using an Ayyyyyyyye Phone!  Until next time, thanks for tuning in!
