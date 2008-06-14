GLASSFISH
GLASSFISH DEPLOYMENT

../../glassfish//lib/ant/bin/ant -f ../../glassfish/jruby/install.xml create-standalone

 cd ..

 ../glassfish/bin/asadmin deploy process


# NEED TO copy public to tmp/war/WEB-INF/public
cp -R public tmp/war/WEB-INF



jruby -S warble 
asadmin deploy process.war

Mysql class path
export CLASSPATH=$CLASSPATH:$GLASSFISH_ROOT/lib/mysql-connector-java-5.0.8-bin.jar

NO NEED TO COPY GEMS NOW-- running standalone false in web.xml..sign does not work...
COPY GEMS ACROSS-- warble a little broken
cp -R $JRUBY_HOME/lib/ruby/gems/1.8/specifications/* tmp/war/WEB-INF/gems/specifications
cp -R $JRUBY_HOME/lib/ruby/gems/1.8/gems/* tmp/war/WEB-INF/gems/gems




Fooling around with the database and stores--example:
[root@svbalance process]# jruby script/console
Loading development environment (Rails 2.0.2)
PROCESS: after boot join about to call initializer env development
database.yml: hostname svbalance.cure.com.ph dbname densha_production hostflag false env development:
after config/openwfe
>> s = WiStore.new
=> #<WiStore id: nil, name: nil, regex: nil>
>> s.name='dispense_pin'
=> "dispense_pin"
>> s.regex='dispense_pin'
=> "dispense_pin"
>> s.save
=> true
>> p=LaunchPermission.new
=> #<LaunchPermission id: nil, groupname: "", url: "">
>> p.url="/process_definitions/dispense_pin.xml"
=> "/process_definitions/dispense_pin.xml"
>> p.save

