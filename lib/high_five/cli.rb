require 'thor'

class CLI < Thor
    include HighFive::Deploy
    include HighFive::Init
end