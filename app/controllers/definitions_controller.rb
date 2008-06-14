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
gem 'openwferu'
require 'openwfe/expressions/raw'


class DefinitionsController < ApplicationController

  layout "densha"

  before_filter :authorize


  #
  # A view on the process definition.
  #
  def view

    @defurl = params[:defurl]
    url = LaunchPermission.to_real_url(@defurl)

    @launch = params[:launch]

    unless LaunchPermission.may_view(url)
      #
      # preventing rogue urls

      flash[:notice] = "off limits"
      redirect_to :controller => "stores"
      return
    end

    begin
      #
      # reading the process definition, if possible...

      @process_definition, @json_process_definition = \
        load_process_definition(url)

    rescue Exception => e

      m = "couldn't parse process definition at #{@defurl}<br/>"
      m += "because of #{e}"

      flash[:notice] = m

      redirect_to :controller => "launch"
      return
    end

    #
    # the process definition as XML or Ruby code

    xml = @process_definition.strip[0, 1] == "<"

    @wrapped_process_definition = if xml

      '<iframe id="xml_process_definition" src="' + @defurl + '"></iframe>'
    else

      "<pre class='rb_process_definition'>\n" + @process_definition + "\n</pre>"
    end
  end

end
