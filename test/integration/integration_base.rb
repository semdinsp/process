
module IntegrationBase

  protected

    def new_session (&block)
      open_session do |ts|

        def ts.user

            @user
        end

        def ts.logs_in_as (user)

          @user = users(user)
          post "login/index", :name => @user.name, :password => user.to_s
          assert_response :redirect
          follow_redirect!
          assert_nil flash[:notice]
          assert_template "stores/index"
          assert_response :success
        end

        def ts.launches (defurl)

          get "launch/launch", :defurl => defurl
          assert_response :redirect
          #puts flash[:notice]
          assert_not_nil flash[:notice]
          follow_redirect!
          assert_template "launch/index"
          assert_response :success
          assert_not_nil session[:launched_fei]

          session[:launched_fei]
        end

        def ts.enters_edition (workitem_id)

          get "workitem/edit/#{workitem_id}"
          assert_response :success
          assert_template "workitem/edit"
          assert_nil flash[:notice]
        end

        def ts.enters_edition_and_it_fails (workitem_id)

          get "workitem/edit/#{workitem_id}"
          assert_not_nil flash[:notice]
          assert_response :redirect
          follow_redirect!
          assert_response :success
          assert_template "stores/index"
        end

        def ts.cancels_edition (workitem_id)

          get "workitem/back/#{workitem_id}"
          assert_nil flash[:notice]
          assert_response :redirect
          follow_redirect!
          assert_response :success
          assert_template "stores/index"
        end

        block.call(ts) if block
      end
    end

    def new_session_as (user, &block)

        new_session do |ts|
          ts.logs_in_as user
          block.call(ts) if block
        end
    end

end
