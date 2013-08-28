graphite-in-a-box
=================

Vagrant configuration to go from nothing to a working Graphite test instance in minutes


# Why?

Last year I was minding my own business at my desk when the storage engineer behind me asked if I knew any Python.   I had been hacking on a Vagrantfile at the time and asked why.  He explained that he was having trouble setting up a program called Graphite.   I wasn't very good at Python, but Graphite I knew!...and Graphite In A Box was born.   

We've been using it for almost a year now at Salesforce.com as a way to get a quick Graphite instance up in minutes for testing code, testing configs, testing monitoring, testing dashboards, you get the picture.

When giving a talk at Agile 2013 this year I guess I mentioned it in my talk.   Someone came up to my after and asked where they could get it, I had to explain that sadly, it's an internal only project.

Until now...

I've changed a few things about the way I originally implemented it to make it easier to maintain, and the code is all new.

# Getting started

Graphite in a box has two requirements

* Vagrant
* Virtualbox

From there getting started is as easy as

1. Git clone this project
2. Add 'graphite' to the end of the line containing 127.0.0.1 in */etc/hosts* (Linux and Mac)
3. vagrant up
4. Go to *http://graphite:8080/

That's it.  Port 2003 and 2004 are mapped as usual.

# Future Plans

* Make the puppet code more organized, right now everything is in one place
* Map the Graphite storage directory as a shared folder for increased storage space
* Support some kind of switches to allow different tools to feed the instance (collectd, etc)

Pull requests, issues, and RFEs welcome.
