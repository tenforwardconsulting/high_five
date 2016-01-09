# High Five

HTML5 build/deploy tool, usually used with PhoneGap but also for standalone web-based apps.

## Installation

Add `gem 'high_five'` to your `Gemfile` or run `gem install high_five`.

After installing the high\_five gem, run

```
$ hi5 init
```

This will bootstrap your project, creating a `config` directory if one isn't present and a few important files inside:

* `config/high_five.rb`

The most most important file. It is the main configuration file and where most configuration takes place. See below for configuration options. It contains sensible defaults.

* `config/high_five/app-common.js`

This is where your shared javascript goes.

If you are using a framework like Sencha, this is where you would include the Sencha files.

At a minimum, you will likely include the main entry point for your app here.

This file is processed with Sprockets, so anything included here will be minified.

Do not add library or remote scripts here. Those should be added with `config/high_five.rb` (see below for how to do this).

* `config/high_five/app-platform.js`

This file is a template and *must* be copied to create `app-<platform>.js` for each platform you have which by default are 'ios' and 'android'.

After creating `app-<platform>.js` for each of your platforms, you can delete this file.

* `config/high_five/index.html.erb`

The entry page for your app.

## Configuration

* `config.app_name`

TODO What does this do? Probably sets some values in some places

* `config.app_id`

TODO What does this do? Probably sets some values in some places

* `config.root`

Defaults to `File.join(File.dirname(__FILE__), '..')` which should be the top-level directory of your app.

* `config.destination`

This is to where high five deploys your app which is set to `www` by default.

If you are using high five with a cordova app, this will need to be set for iOS and Android separately (uncomment the appropriate lines in the platforms section of the config).

* `config.windows!`

Use this if you're on windows and having problems with a strange ExecJS RuntimeError.

* `config.compass_dir`

If set, high five will run `compass compile` in the given directory before doing anything else.

This makes it possible, for example, to write sass in `resources/sass/app.sass` and have it compiled to `resources/css/app.css` which can then be included into your app with the `stylesheets` method (see below).

NB: Make sure you have specified your compass config in `config.rb` in this directory!

* `config.minify`

TODO Write some words about how minifying works and what you might need installed based on the variations options for minifying.

* `config.manifest`

Generate [app cache manifest](http://www.w3schools.com/html/html5_app_cache.asp).
This is usually specified in the `:web` platform, and the manifest file is only created when the environment is `production`.
You'll only use this if you're developing a javascript web app (e.g. an ember or angular app).

* `config.dev_index`

Copy generated index.html to given value, index-debug.html by default. The copied file will reference your source files and not the compiled files so that you do not need to deploy between every since code change. You'll only need to deploy when you add/remove a source file.

### Bundling assets into your app

The important high five config options for assets are `assets`, `javascripts`, and `stylesheets`.

* `assets`

This method takes either a directory or file name. When you deploy, those directories/files are copied into `config.destination`.

For example, to include images into your app, first create `resources/images`.
Then in the config file, add `config.assets "resources/images"`. When you deploy it will create `<destination>/resources/images` containing all of your images.
You can now reference your images with respect to the `<destination>` directory. So a link to an image in your app would look like `resources/images/foobar.png`.

* `javascripts`, `stylesheets`

To include a javascript file or stylesheet, use the `javascripts` or `stylesheets` method respectively.
This will add that file to `<destination>/index.html` when deploying.
See `config/high_five/index.html.erb` to see how this is done.

For example, let's say we want to include [moment.js](http://momentjs.com/).
First we save the minified<sup>[1]</sup> file somewhere, `resources/vendor/javascripts`, for example.
Then we add `config.javascripts "resources/vendor/javascripts/moment.min.js"` to our config file.
When we deploy, that file will be included in `<destination>/index.html`!

The same is true for stylesheets.

Don't forget that the file you give to the `javascripts` and `stylesheets` methods can be anything.
That means if you want to manage dependencies with npm, for example, you can do `config.javascripts "node_modules/foo/bar.js"`!

[1] NB: hi5 does *not* minify your assets! Make sure you use the minified versions of your assets.

#### Advanced example

Let's say we want to add [FontAwesome](http://fontawesome.io) to our mobile app.

First, we extract the FontAwesome toolkit to `resources/vendor/font-awesome-4.5.0`, deleting everything except the css and fonts directories.

Then we have high five include that directory with `config.assets "resources/vendor/font-awesome-4.5.0"`.

Then we tell high five to include the FontAwesome css file with `config.stylesheets "resources/vendor/font-awesome-4.5.0/css/font-awesome.min.css"`.
This includes the FontAwesome stylesheet in `<destination>/index.html` which gives us access to the FontAwesome font-family and the `.fa` classes.

That's it!

Follow a similar procedure for any complex resource you wish to include.

* `config.setting`

Using the `config.setting` method, you can create key/value pairs which will be made available in your javascript under `HighFive.Settings`.

For example, `config.setting apiEndpoint: "http://dev.example.com/api"` will make `HighFive.Settings.apiEndpoint` return "http://dev.example.com/api".

* `config.platform`

Using the `config.platform` method defines your target platforms and allows you to create platform-specific configurations.
Platforms are what you tell high five to deploy with the `hi5 deploy <platform>` command.
At a minimum this usually includes iOS, Android, and "web" for testing without having to deploy to a device.

The method takes a block whose argument is the same type of config object as the top level config object.

For example, let's say you want to include iOS specific assets into the iOS version of your app.
```ruby
config.platform :ios do |ios|
  ios.assets "resources/ios"
end
```

When `hi5 deploy ios` is ran, high five will include `resources/ios` in the destination.

For each platform, you need to make sure `config/high_five/app-<platform>.js` exists.
See current examples for the minimum contents required in these files.
This is important for INSERT REASONS HERE.  (TODO Why not just say `ios.javascripts "ios_specific_javascript_file.js"` instead?)

* `config.environment`

Environments function like platforms: they allow you to further specify or override either base or platform-specific settings for each of your environments (production/qa/staging/etc).
That is, they take precedence over platform configurations.

Their primary purpose is to set your app's endpoint, but can be used for anything.
e.g. You may want a non-minified asset deployed to your device during development, but the minified version deployed all other times.

An environment is specified with either `-e` or `--environment` when running `hi5 deploy`.

e.g.

  `hi5 deploy <platform> --environment lan`

  `hi5 deploy <platform> -e production`

At a minimum, you will probably want `:lan` (so you can deploy an app which is pointed at a server running on your machine) and an entry for each environment your app has (production/staging/qa/etc).
```ruby
config.environment :lan do |lan|
  ip = Socket.ip_address_list.detect { |intf| intf.ipv4? && !intf.ipv4_loopback? && !intf.ipv4_multicast? }.ip_address
  lan.setting apiEndpoint: "http://#{ip}:3000" # Or however you specify your server's location.
  # lan.javascripts "resources/vendor/javascripts/some-library-debug-all.js"
end

config.environment :dev do |dev|
  dev.setting apiEndpoint: "http://dev.example.com"
  # dev.javascripts "lib/some-library-minified.js"
end

config.environment :production do |production|
  production.setting apiEndpoint: "http://example.com"
  # production.javascripts "lib/some-library-minified.js"
  # production.minify :uglifier # or :yui
end
```

## Usage

* `$ hi5 deploy <platform> -e <environment>`

This will build your application for a specific platform with the settings for the given environment to the destination directory specified in `config/high_five.rb`.

* `$ hi5 <android|ios>:set_icon path/to/icon.png`

By default, high\_five uses ChunkyPNG to resize the icon, but this almost always bad icons.
We highly recommend adding the [rmagick](https://github.com/rmagick/rmagick) gem (which depends on imagemagick) to your Gemfile along with high\_five.
High Five will detect that you have rmagick installed and will use it to generate good icons.

* `$ hi5 <android|ios>:set_version -v "1.0" -b 200`

This sets the publicly visible "version string" and the build number. They are in either `info.plist` or `AndroidManifest.xml` for iOS and Android, respectively.

* `$ hi5 dist <platform>`

Compiles the native application to an IPA or APK. This is optional, and instead you may use Xcode, Android Studio, gradle, or any other similar tool.

If you pass it the `--install` flag, it will attempt to install to a connected device.

* There's probably more high five commands that should be documented. If you find any not listed here, open an issue or submit a PR.

### Development Usage

#### Build and deploy for browser

`hi5 deploy web`

Then open index-debug.html inside of google chrome with web security disabled (`google-chrome --disable-web-security`)

#### Build and deploy for device

Make sure your device and computer are on the same wifi network (subnet).

Make sure your server accepts connects from devices on the same subnet.

e.g. For rails, start your server like this:

`rails server -b 0.0.0.0`

##### Android

According to Brett, only the _first_ time you put a build on your device, you need to do this (replace the keystore, alias, password, and alias password with the correct values for your app):

`hi5 deploy android --environment lan && hi5 dist android --environment lan --install --ant -o "Foobar-android--adhoc" -e --ant-flags="-Dkey.store=foobar.keystore -Dkey.alias=foobar -Dkey.store.password=foobar -Dkey.alias.password=foobar"`

TODO: hi5 dist should use the debug android target instead of release by default if it doesn't detect signing parameters. It should also generate a big warning about that.

After that, this should be sufficient:

`hi5 deploy android -e lan && hi5 dist android -e lan --install`

*However*, this did not work for me. I had to always use the first command or else hi5 just kept installing the initial build.

##### iOS

TODO Write words here. Probably something with Xcode.

## Reading the source

TODO Write words here.

## Ruby

If you're on Windows, you need both Ruby and the Dev tools. There is a great tutorial here:

https://github.com/oneclick/rubyinstaller/wiki/development-kit

## TODO
* Have `hi5 init` create resources/images
* Confirm the `assets` method can take a file.
* Just create the app-ios.js and app-android.js files instead of app-platform.js. This would get us a little closer to "just working".
