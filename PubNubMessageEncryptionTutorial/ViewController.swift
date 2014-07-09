//
//  ViewController.swift
//  PubNubMessageEncryptionTutorial
//
//  Created by Eric Theis on 7/9/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        var myConfig = PNConfiguration(forOrigin: "pubsub.pubnub.com", publishKey: "demo", subscribeKey: "demo", secretKey: nil, cipherKey: "my_super_secret_cipherkey")
        
        PubNub.setConfiguration(myConfig)
        
        PubNub.connect()
        
        var myChannel = PNChannel.channelWithName("my_secure_channel", shouldObservePresence: true) as PNChannel
        
        PNObservationCenter.defaultCenter().addClientConnectionStateObserver(self) { (origin: String!, connected: Bool!, error: PNError!) in
            if connected {
                println("OBSERVER: Successful Connection!");
                PubNub.subscribeOnChannel(myChannel)
            } else if !connected {
                println("OBSERVER: \(error.localizedDescription), Connection Failed!");
            }
        }
        
        PNObservationCenter.defaultCenter().addClientChannelSubscriptionStateObserver(self) { (state: PNSubscriptionProcessState, channels: [AnyObject]!, error: PNError!) in
            switch state {
            case PNSubscriptionProcessState.SubscribedState:
                println("OBSERVER: Subscribed to Channel: \(channels[0])")
                PubNub.sendMessage("Can you hear me?", toChannel: channels[0] as PNChannel)
            case PNSubscriptionProcessState.NotSubscribedState:
                println("OBSERVER: Not subscribed to Channel: \(channels[0]), Error: \(error)")
            case PNSubscriptionProcessState.WillRestoreState:
                println("OBSERVER: Will re-subscribe to Channel: \(channels[0])")
            case PNSubscriptionProcessState.RestoredState:
                println("OBSERVER: Re-subscribed to Channel: \(channels[0])")
            default:
                println("OBSERVER: Something went wrong :(")
            }
        }
        
        PNObservationCenter.defaultCenter().addMessageReceiveObserver(self) { (message: PNMessage!) in
            println("OBSERVER: Channel: \(message.channel), Message: \(message.message)")
        }
        
        PNObservationCenter.defaultCenter().addMessageProcessingObserver(self) { (state: PNMessageState!, data: AnyObject!) in
            switch state {
            case PNMessageState.Sent:
                println("OBSERVER: Message Sent.")
            case PNMessageState.Sending:
                println("OBSERVER: Message Sending.")
            case PNMessageState.SendingError:
                println("OBSERVER: ERROR: Failed to Send Message")
            default:
                println("OBSERVER: Something went wrong :(")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

