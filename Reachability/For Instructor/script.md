# Screencast Metadata

-----

### Language, Editor and Platform versions used in these screencasts:

**Language:** Swift 4
**Platform:** iOS 11
**Editor**: Xcode 9.3

-----

### Screencast Title:
Reachablity in iOS

### Description:
[TODO]


TH
------------
Hi everybody, this is Spiro, back with another screencast. Today we're going check out a how to handle for situations where are apps are trying to access the Internet but for whatever reason it is not available.. Most applications you'll write will have some sort of interaction that will require a connection to the Internet, whether it's posting to a game in a leaderboard, grabbing updates, or sending a message. As we develop with a simulator, we often take for granted that the connection is always on. So, what happens if the user's Wi-Fi turns off or if they enter a dead zone? How can we let them know that there's not Internet connection available  -- and, what can we do to reengage them once the connection is available?

In this screencast we'll take a look at the Reachability network helper class to help us check the network state of the user's device. We'll also take a look at implementing a network check before a performing an action that requires an internet connection, and then explore how we can monitor our connection status and handle network changes using a popular implementation to make this a little easier. 

So let's get started.

CODING/SCREEN
------------
Inside the start project we'll import the SystemConfiguration framework.
We'll then use the method SCNetworkReachablityCreate. With which takes a domain name.  The first parameter is the allocator, we'll  pass nil to use the default one. One thing to keep in mind is that we aren't checking if it's possible to connect somewhere, we are just checking whether the interface is available and would allow a connection.

private let reachability = SCNetworkReachabilityCreateWithName(nil, "www.raywenderlich.com")


Next, we'll create a function called checkReachable() that will call SCNetworkReachability.
SCNetworkReachability provides the network state information with a set of flags-SCNetworkReachabilityFlags. 


private func checkReachable()
    {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(self.reachability!, &flags)
        
        if (isNetworkReachable(with: flags))
        {
            print (flags)
            if flags.contains(.isWWAN) {
                self.alert(message:"via mobile",title:"Reachable")
                return
            }
            
            self.alert(message:"via wifi",title:"Reachable")
        }
        else if (!isNetworkReachable(with: flags)) {
            self.alert(message:"Sorry no connection",title: "unreachable")
            print (flags)
            return
        }
    }

We'll then create a function to interpret that flag for checkReachable to interpret the flag and have checkReachable alert the user as to what the current network status is. 

private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }

Now run, Let's go ahead and toggle our internet connection. 
You should see alerts with status information appear based on the current status. 

In this case we're just sending an alert depending on the network condition, but what you might do is alert the user if their Internet condition is not available, but then execute your code if you isNetworkReach is true.

TH
------------

Another neat feature of the Reachability class it that you can use it to also detect for the different connection used such as 3G and LTE which could be helpful to let your user know that they might be facer longer upload/download times when using your app.

Now, what if we want to continuously check for a network condition. Suppose we want to not only let the user know that the Internet is not available network making a network request, but then automatically complete that request when the network becomes available.  

Reachability instance (reachability) continuously fires ReachabilityChangedNotification whenever there is a change in the network reachability status. We will set up a function to listen to that notification. This notification will contain the reachability instance as an object.

TH / Show GitHub page
------------
To do something like that we'll leverage a popular class put together by Ashely 
This class does a good job abstracting a lot of the nuances inside the Reachability class which is a little outside the scope of this screencast. You can manually put this class into your project and call it within ViewController. I've added it inside our starter project.

CODE / SCREEN
------------

So let's go ahead and add an instance of the class and then modify our ViewController to listen for those events. 

let reachability = Reachability()!

  NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    do{
      try reachability.startNotifier()
    }catch{
      print("could not start reachability notifier")
    }



And then we'll create the function to notify us based on the network change

  @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .none:
            print("Network not reachable")
        }
    }

Now run, Let's go ahead and toggle our internet connection. 
You should see the information in the debugger change based on our connection. 

To stop events, we can go ahead and add 

reachability.stopNotifier()
NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)

TH
------------

After we have successfully gotten a connection and then perform the action we need. 

There you have it! You should now be able to check for an internet connection using to methods, by checking for network status before performing a network function, and setting up anevents that will continuously notify your app of the network connection change. Before we go, I'd like to thank James Taylor for tech editing this screencast. And remember, before you make that handshake.. remember to reach out... alright i'm out!

