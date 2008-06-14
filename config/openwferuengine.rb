
#$LOAD_PATH << "~/openwfe-ruby/lib"
#$LOAD_PATH << "vendor/openwfe-ruby/lib"
# scott $LOAD_PATH << "../openwfe-ruby/lib"

require 'rubygems'

#
# the workflow engine

#puts "CONFIG: In openwfeengine..."
begin

  require 'openwfe/engine/file_persisted_engine'
  require 'openwfe/extras/participants/activeparticipants'

rescue LoadError
  #
  # soft dependency on 'openwferu' and 'openwferu-extras'
  #
  puts
  puts
  puts "'openwferu' and/or 'openwferu-extras' are missing."
  puts "You can install them with :"
  puts
  puts "  [sudo] gem install -y openwferu"
  puts "  [sudo] gem install -y openwferu-extras"
  puts
  puts
  puts "alternatively you can unpack openwferu at the same level"
  puts "as your application (../openwfe-ruby/)"
  puts "or in your home directory (~/openwfe-ruby/)"
  puts
  puts
  puts "NOTE : with a trunk (svn checkout) version of Densha, use a"
  puts "checked out version of OpenWFEru as well :"
  puts
  puts "    svn checkout http://openwferu.rubyforge.org/svn/trunk/openwfe-ruby"
  puts
  puts "Do this checkout in the same dir containing the densha/ directory."
  puts
  puts
  exit 1
end

#
# requiring the json gem
#puts "WFE: requiring json"
begin
  gem 'json_pure'
#  puts "GEM:  ater json pure"
  require 'json'
 # puts "after require json"

rescue LoadError => le
  #
  # soft dependency on 'json_pure'
  #
  puts
  puts
  puts "'json_pure' is missing. You can install it with :"
  puts
  puts "  [sudo] gem install -y json_pure"
  puts
  puts
  #puts le
  exit 1
end
#puts "before if"
#
# adding the dev_data if necessary

if $0 =~ /script\/server/ and RAILS_ENV == 'development'

  users = User.find(:all)

  require 'db/dev_data' if users.size < 1
end


#
# instantiates the workflow engine

#require 'logger'

ac = {}

ac[:work_directory] = "work_#{RAILS_ENV}"
  #
  # where the workflow engine stores its rundata
  #
  # (note that workitems are stored via ActiveRecord as soon as they are
  #  assigned to an ActiveStoreParticipant)
#puts "fulling around with ac"

#ac[:logger] = Logger.new("log/openwferu_#{RAILS_ENV}.log", 10, 1024000)
ac[:logger] = RAILS_DEFAULT_LOGGER
#puts "created logger"
ac[:logger].level = if RAILS_ENV == "production" 
  Logger::INFO
else
  Logger::DEBUG
end

ac[:ruby_eval_allowed] = true

#puts "initiating cached file engine"
$openwferu_engine = OpenWFE::Engine.new(ac)

#
# register a participant per workitem store
#puts "CONFIG: before class"

class << $openwferu_engine

  #
  # Reloads the store participants as participants to the engine.
  # Returns how many store participants were [re]registered.
  #
  def reload_store_participants

    stores = []
    begin
      stores = WiStore.find(:all)
    rescue Exception => e
    end

    stores.each do |store|
      $openwferu_engine.register_participant( 
        store.regex, 
        OpenWFE::Extras::ActiveStoreParticipant.new(store.name))
    end

    stores.size
  end
end

$openwferu_engine.reload_store_participants
  #
  # reload now.


at_exit do
  #
  # make sure to stop the workflow engine when 'densha' terminates

  $openwferu_engine.stop
end

#puts "CONFIG:  openwfe fei mods"
#
# adding a rails_url method to FlowExpressionId

class OpenWFE::FlowExpressionId

    def rails_url

      url = self.workflow_definition_url

      if url.match("^public/")
        url[6..-1]
      else
        url
      end
    end
end

#
# Opening the class to add some helper methods
#
#puts "CONFIG openwfe workitem"
class OpenWFE::Extras::Workitem

  #
  # Returns a nicer representation of the FlowExpressionId identifier
  # for this workitem
  #
  def fei_to_s

    ffei = self.full_fei

    "#{ffei.wfid} #{ffei.expname} #{ffei.expid} - " +
    "#{ffei.wfname} #{ffei.wfrevision}"
  end

  #
  # Returns the activity (string) if set in the 'params' of the workitem.
  #
  def activity

    params = fields_hash["params"]
    return nil unless params
    params["activity"]
  end
end

#
# add your participants there

require 'config/openwferu_participants'

