#
#--
# Copyright (c) 2008, John Mettraux, OpenWFE.org
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

class ProcessController < ApplicationController

  layout "densha"

  before_filter :authorize_admin

  #
  # Opens a workitem in edition mode
  #
  def index

    if request.method == :post
        return update_expression_data if params[:hash_form_json]
        return update_expression
    end

    @wfid = params[:id]
    @show_unapplied = (params[:show_unapplied] == 'true')

    #
    # get process stack (and a bit more)

    @process_stack = $openwferu_engine.process_stack @wfid, @show_unapplied
    @paused = $openwferu_engine.is_paused? @wfid
    @status = $openwferu_engine.process_status @wfid

    if @process_stack.size < 1
      redirect_to :controller => :processes
      return
    end

    @process_stack = @process_stack.sort_by { |fe| fe.fei.expid }

    @workitems = @process_stack.inject([]) do |r, fexp|
      r << fexp.fei.expid \
        if fexp.respond_to?(:applied_workitem) and fexp.applied_workitem
      r
    end

    #
    # prepare process definition for fluo rendering

    @process_definition, @json_process_definition =
      LaunchPermission.load_process_definition(
        @process_stack[0].fei.workflow_definition_url)
  end

  #
  # Cutting / cancelling a branch of the expression tree.
  #
  def abort

    wfid = params[:id]
    expid = params[:expid]
    su = params[:show_unapplied]

    ps = $openwferu_engine.process_stack wfid, true
    fexp = ps.find { |fexp| fexp.fei.expid == expid }

    if not fexp
      #flash[:notice] = "process instance #{wfid} is gone"
      redirect_to :action => :index, :id => wfid, :show_unapplied => su
      return
    end

    $openwferu_engine.cancel_expression fexp.fei
      # fexp may have gone...

    sleep 0.350

    flash[:notice] = "removed expression #{expid} of #{wfid}"
    redirect_to :action => :index, :id => wfid, :show_unapplied => su
  end

  protected

    #
    # Saves new version of variables / workitem payload
    #
    def update_expression_data

      su = params[:show_unapplied]

      fei = params['hash_form_fei']
      fei = JSON.parse fei
      fei = OpenWFE::FlowExpressionId.from_h fei

      data = params['hash_form_json']
      data = JSON.parse data

      $openwferu_engine.update_expression_data fei, data

      redirect_to :id => fei.wfid, :show_unapplied => su
    end

    #
    # Replaces an entire process expression with a new one.
    #
    def update_expression

      exp = params[:expression]
      wfid = params[:id]

      if exp and exp != ''

        #fname = exp.original_filename

        begin

          fexp = YAML.load exp.read

          raise "not an expression" \
            unless fexp.is_a?(OpenWFE::FlowExpression)

          fei = fexp.fei

          raise "expression doesn't belong to current process '#{wfid}'" \
            unless fei.wfid == wfid

          $openwferu_engine.update fexp

          flash[:notice] = 
            "uploaded new version of "+
            "#{fei.wfid} #{fei.expid} #{fei.expression_name}"

        rescue Exception => e

          flash[:notice] = "couldn't read expression (#{e})"
        end
      else

        flash[:notice] = "nothing uploaded"
      end

      redirect_to :id => params[:id], :show_unapplied => params[:show_unapplied]
    end

end

