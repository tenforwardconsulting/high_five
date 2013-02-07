class HighFive::Config
    attr_accessor :root, #Root of the project 
                  :index #relative path to index.html


    def self.configure(&block) 
        config = HighFive::Config.new
        yield config

        #validate
    end


end