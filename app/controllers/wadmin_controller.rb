#
#--
# Copyright (c) 2007, John Mettraux, OpenWFE.org
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
# . Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.  
# 
# . Redistributions in binary form must reproduce the above copyright notice, 
#   this list of conditions and the following disclaimer in the documentation 
#   and/or other materials provided with the distribution.
# 
# . Neither the name of the "OpenWFE" nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#++
#

#
# Made in Japan
#
# john.mettraux@openwfe.org
#

class WadminController < ApplicationController

  layout "densha"

  before_filter :authorize_admin


  def index

    @users = User.find(:all)
    @groups = Group.find(:all)
    @storepermissions = StorePermission.find(:all)
    @stores = WiStore.find(:all)
    @launchpermissions = LaunchPermission.find(:all)
  end

  #
  # Deletes a record (user, group, launch permission, ...).
  #
  def delete

    oid = params[:id]
    klassname = params[:klass]
    klass = to_class(klassname)

    o = klass.find(oid)

    $openwferu_engine.unregister_participant(o.regex) if klass == Store

    o.destroy \
        unless (klass == User and o.name == "admin")

    render_updated_records klassname
  end

  #
  # Adds a new element
  #
  def add

    klassname = params[:klass]
    klass = to_class(klassname)

    params.delete :klass
    params.delete :action
    params.delete :controller

    o = klass.new
    params.each do |k, v|
      o.send("#{k}=".intern, v.strip)
    end
    o.save!

    render_updated_records klassname
  end

  protected

    WADMIN_CLASSES = {
      "User" => User, 
      "Group" => Group, 
      "LaunchPermission" => LaunchPermission, 
      "WiStore" => WiStore, 
      "StorePermission" => StorePermission
    }

    #
    # Avoiding an 'eval'
    #
    def to_class (classname)

      WADMIN_CLASSES[classname]
    end

    def render_updated_records (klassname)

      klass = to_class(klassname)

      records = klass.find(:all)

      render :update do |page|

        page.replace_html(
          "wadmin_#{klassname}", 
          :partial => "index_#{klassname.downcase}s",
          :locals => { :records => records })
      end
    end

end

