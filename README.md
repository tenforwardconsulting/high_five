high_five
=========

HTML5 build/deploy tool, usually used with PhoneGap. 

Installation
============

  $ gem install high_five
  $ cd my_mobile_project
  $ hi5 init

This will bootstrap your project, creating a ```config``` directory if one isn't present, 
and also creating a few important files inside, most importantly high_five.rb. 

Configuration
=============


Usage
=====

  $ hi5 deploy <platform> -e <environment> 

This will build your application for a specific platform to the directory specified in high_five.rb.  


