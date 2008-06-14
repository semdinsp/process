
#
# Put your openwferu participants here.
#
# see examples of participant at
#     http://openwferu.rubyforge.org/participants.html
#
# and also at
#     http://viewvc.rubyforge.mmmultiworks.com/cgi/viewvc.cgi/trunk/openwfe-ruby/examples/engine_template.rb?root=openwferu&view=markup
#


#
# A stupid "toto" participant, simply outputs a message to the console (if any)
# each time it receives a workitem.
#
$openwferu_engine.register_participant "toto" do |workitem|

  puts
  
  puts "toto received a workitem"
    puts "#{workitem.to_s}"
  puts "and immediately sent it back to the engine" #implicitely
  puts
end


#
# Note that store participant are registered in config/openwferu_engine.rb
#

#
# When all the participants have been registered, reschedule temporal
# expressions left from previous run (restart).
#
$openwferu_engine.reschedule

