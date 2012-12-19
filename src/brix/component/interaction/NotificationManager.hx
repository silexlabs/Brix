/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.interaction;

import js.Lib;
import js.Dom;

import haxe.Timer;
import haxe.Template;

import brix.util.DomTools;
import brix.component.ui.DisplayObject;

typedef Notification = Dynamic;
typedef NotificationEvent = {
	iconUrl:String,
	title:String,
	body:String,
}
/**
 * NotificationManager class
 * This class listens to the other components notification events and displays notifications to the user
 * It uses the native javascript notification API, or a custom brix notification system
 * For the custom notification system, you are expected to put a DIV in your HTML with css class name "notification-zone" 
 * and a haxe template in it which loops on the notifications variable
 */
class NotificationManager extends DisplayObject
{
	/**
	 * duration of a message in ms
	 */
	public static inline var DEFAULT_MESSAGE_DURATION = 10000;
	/**
	 * success image 
	 */
	public static inline var DEFAULT_SUCCESS_ICON = "../admin/assets/notification-info.png";
	/**
	 * error image 
	 */
	public static inline var DEFAULT_ERROR_ICON = "../admin/assets/notification-error.png";
	/**
	 * class name to set on the node which is the notification zone
	 */
	public static inline var CSS_CLASS_NOTIFICAITON_ZONE = "notification-zone";
	/**
	 * event name to dispatch when you want to send a notification
	 */
	public static inline var NOTIFICATION_EVENT = "notificationEvent";
	/**
	 * list of displayed notifications
	 */
	private var notifications:Array<NotificationEvent>;
	/**
	 * template to displaye custom notifications
	 */
	private var notificationTemplate:String;
	/**
	 * div tag which contains the template for custom notifications
	 */
	private var notificationZone:HtmlDom;

	////////////////////////////////////////////////////////////////
	// static helper functions
	////////////////////////////////////////////////////////////////
	/**
	 * send a notification request on a node
	 */
	public static function notifySuccess(title:String, body:String, ?rootElement:HtmlDom=null) 
	{
		notify(DEFAULT_SUCCESS_ICON, title, body, rootElement);
	}
	/**
	 * send a notification request on a node
	 */
	public static function notifyError(title:String, body:String, ?rootElement:HtmlDom=null) 
	{
		notify(DEFAULT_ERROR_ICON, title, body, rootElement);
	}
	/**
	 * send a notification request on a node
	 */
	public static function notify(iconUrl:String, title:String, body:String, ?rootElement:HtmlDom=null) 
	{
		if (rootElement==null)
		{
			var elements = Lib.document.body.getElementsByClassName("NotificationManager");
			if (elements.length <= 0)
			{
				throw("Error: could not find a NotificationManager in the DOM");
			}
			rootElement = elements[0];
		}
		// dispatch a custom event
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(NotificationManager.NOTIFICATION_EVENT, true, true, {
			iconUrl:iconUrl,
			title:title,
			body:body,
		});
		rootElement.dispatchEvent(event);
	}
	////////////////////////////////////////////////////////////////
	// main methods
	////////////////////////////////////////////////////////////////
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);

		// for custom notification system
		notifications = new Array();
		notificationZone = DomTools.getSingleElement(rootElement, CSS_CLASS_NOTIFICAITON_ZONE, true);
		notificationTemplate = notificationZone.innerHTML;
		notificationZone.innerHTML = "";

		// for the native notification system
		initNotificationsCallback = callback(initNotifications);
		rootElement.addEventListener("click", initNotificationsCallback, false);

		// listen to the other components events
		rootElement.addEventListener(NOTIFICATION_EVENT, cast(onNotificationReceived), false);
	}
	private var initNotificationsCallback:MouseEvent->Void;
	private function initNotifications(e:MouseEvent) 
	{
		if (!hasPermission())
		{
			trace("initNotifications");
			requestPermission(null, null);
		}
		rootElement.removeEventListener("click", initNotificationsCallback, false);
	}
	/**
	 * callback for the notificaiton event
	 * check if there is a notification system
	 * check if notifications are allowed and ask for permission if not
	 * send notification or custom notification
	 */
	private function onNotificationReceived(e:CustomEvent)
	{
		trace("onNotificationReceived "+e.detail+" - "+hasNotification()+" - "+hasPermission());
		if (hasNotification())
		{
			if (hasPermission())
			{
				sendNotification(e.detail);
			}
			else
			{
				//requestPermission(callback(sendNotification, e.detail), callback(sendCustomNotification, e.detail));
				requestPermission(null, null);
				sendCustomNotification(e.detail);
			}
		}
		else
		{
			sendCustomNotification(e.detail);
		}
	}
	////////////////////////////////////////////////////////////////
	// native javascript notification API
	////////////////////////////////////////////////////////////////
	/**
	 * check if notification API is supported
	 */
	private function hasNotification():Bool
	{
		return untyped window.webkitNotifications != null;
	}
	/**
	 * check if notification permission is granted
	 */
	private function hasPermission():Bool
	{
		return hasNotification() && untyped window.webkitNotifications.checkPermission() == 0;
	}
	/**
	 * callback for the permission request 
	 */
	private function permissionRequestCallback(acceptCallback:Void->Void, denyCallback:Void->Void) 
	{
		trace("permissionRequestCallback "+hasPermission());
		if (hasNotification() && hasPermission())
		{
			if (acceptCallback != null)
				acceptCallback();
		}
		else
		{
			if (denyCallback != null)
				denyCallback();
		}
	}
	/**
	 * request permission to notify
	 */
	private function requestPermission(?acceptCallback:Void->Void=null, ?denyCallback:Void->Void=null) 
	{
		trace("requestPermission ");
		if (hasNotification())
		{
			if (hasPermission()) 
			{
				trace("PERMISSION ALLOWED");
				acceptCallback();
			} else {
				trace("PERMISSION ASKED");
				untyped window.webkitNotifications.requestPermission(callback(permissionRequestCallback, acceptCallback, denyCallback));
			}
		}
		else
		{
			trace("NO NOTIFICATION SYSTEM");
		}
	}
	/**
	 * send a notification
	 */
	private function sendNotification(e:NotificationEvent, ?duration:Int=DEFAULT_MESSAGE_DURATION) 
	{
		trace("sendNotification "+e);
		if (!hasNotification())
		{
			trace("NO NOTIFICATION SYSTEM");
			throw("NO NOTIFICATION SYSTEM");
		}
		if (!hasPermission())
		{
			trace("NO NOTIFICATION PERMISSION");
			throw("NO NOTIFICATION PERMISSION");
		}
		var notification:Notification;
		notification = untyped window.webkitNotifications.createNotification(e.iconUrl, e.title, e.body);
		notification.show();

		if (duration>0)
		{
			Timer.delay(callback(destroyNotification,notification), duration);
		}
	}
	/**
	 * destroy a previously created notification
	 */
	private function destroyNotification(notification:Notification) 
	{
		notification.cancel();
	}
	////////////////////////////////////////////////////////////////
	// custom javascript notification API
	////////////////////////////////////////////////////////////////

	/**
	 * send a notification
	 */
	private function sendCustomNotification(notification:NotificationEvent, ?duration:Int=DEFAULT_MESSAGE_DURATION) 
	{
		trace("sendCustomNotification "+notification);
		if (duration>0)
		{
			Timer.delay(callback(destroyCustomNotification, notification), duration);
		} 
		notifications.push(notification);
		refreshNotifications();
	}
	/**
	 * refresh the notification zone with the data in the notifications array
	 */
	private function refreshNotifications() 
	{
		trace("refreshNotifications "+notifications+" - "+notificationTemplate);
		var t = new Template(notificationTemplate);

		try{
			notificationZone.innerHTML = t.execute({notifications:notifications});
		}
		catch(e:Dynamic)
		{
			trace("Error: "+e);
		}
		trace("refreshNotifications "+notificationZone.innerHTML);
	}
	/**
	 * destroy a previously created notification
	 */
	private function destroyCustomNotification(notification:Notification) 
	{
		notifications.remove(notification);
		refreshNotifications();
	}
}