High Five
=========

HTML5 build/deploy tool, usually used with PhoneGap but also for standalone web-based apps

Ruby
====

If you're on Windows, you need both Ruby and the Dev tools.  There is a great tutorial here: 

https://github.com/oneclick/rubyinstaller/wiki/development-kit

Installation
============

  $ gem install high_five
  $ cd my_mobile_project
  $ hi5 init

This will bootstrap your project, creating a ```config``` directory if one isn't present, 
and also creating a few important files inside, most importantly high_five.rb. 

Configuration
=============

```hi5 init``` will create all the directories you need, and almost all of your configuration will happen inside of ```config/high_five.rb```.  It is reasonably well documented and contains a lot of sensible defaults.  I hope to improve the documentation here over time, but for now go read ```high_five.rb```


Usage
=====

  $ hi5 deploy <platform> -e <environment> 

This will build your application for a specific platform to the directory specified in high_five.rb.  


