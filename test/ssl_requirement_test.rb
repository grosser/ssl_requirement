require 'rubygems'
require 'action_pack'
require 'action_controller'
require 'test/unit'
require 'redgreen'
$LOAD_PATH << 'lib'

if ActionPack::VERSION::MAJOR > 2
 require 'action_dispatch/testing/test_process'

 ROUTES = ActionDispatch::Routing::RouteSet.new
 ROUTES.draw do
   match ':controller(/:action(/:id(.:format)))'
 end
 ROUTES.finalize!

# funky patch to get @routes working, in 'setup' did not work
 module ActionController::TestCase::Behavior
   def process_with_routes(*args)
     @routes = ROUTES
     process_without_routes(*args)
   end
   alias_method_chain :process, :routes
 end

 class ActionController::Base
   self.view_paths = 'test/views'

   def self._routes
     ROUTES
   end
 end
else
 require 'action_controller/test_process'

 ActionController::Routing::Routes.reload rescue nil
 ActionController::Base.cache_store = :memory_store

end





require 'ssl_requirement'

class SslRequirementController < ActionController::Base
  include SslRequirement
  
  ssl_required :a, :b
  ssl_allowed :c
  
  def a
    render :nothing => true
  end
  
  def b
    render :nothing => true
  end
  
  def c
    render :nothing => true
  end
  
  def d
    render :nothing => true
  end
  
  def set_flash
    flash[:foo] = "bar"
    render :nothing => true
  end
end

class SslRequirementTest < ActionController::TestCase
  def setup
    @controller = SslRequirementController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  test "redirect to https preserves flash" do 
    get :set_flash
    get :b
    assert_response :redirect
    assert_equal "bar", flash[:foo]
  end

  test "not redirecting to https does preserve the flash" do
    get :set_flash
    get :d
    assert_response :success
    assert_equal "bar", flash[:foo]
  end

  test "redirect to http preserves flash" do
    get :set_flash
    @request.env['HTTPS'] = "on"
    get :d
    assert_response :redirect
    assert_equal "bar", flash[:foo]
  end

  test "not redirecting to http does preserve the flash" do
    get :set_flash
    @request.env['HTTPS'] = "on"
    get :a
    assert_response :success
    assert_equal "bar", flash[:foo]
  end

  test "required without ssl" do
    assert_not_equal "on", @request.env["HTTPS"]
    get :a
    assert_response :redirect
    assert_match %r{^https://}, @response.headers['Location']
    get :b
    assert_response :redirect
    assert_match %r{^https://}, @response.headers['Location']
  end

  test "required with ssl" do
    @request.env['HTTPS'] = "on"
    get :a
    assert_response :success
    get :b
    assert_response :success
  end

  test "disallowed without ssl" do
    assert_not_equal "on", @request.env["HTTPS"]
    get :d
    assert_response :success
  end

  test "disallowed with ssl" do
    @request.env['HTTPS'] = "on"
    get :d
    assert_response :redirect
    assert_match %r{^http://}, @response.headers['Location']
  end

  test "allowed without ssl" do
    assert_not_equal "on", @request.env["HTTPS"]
    get :c
    assert_response :success
  end

  test "allowed with ssl" do
    @request.env['HTTPS'] = "on"
    get :c
    assert_response :success
  end
end

class SslRequiredAllController < ActionController::Base
  include SslRequirement
  ssl_required

  def a
    render :nothing => true
  end
end


class SslRequiredAllTest < ActionController::TestCase
  def setup
    @controller = SslRequiredAllController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  test "allows ssl" do
    @request.env['HTTPS'] = "on"
    get :a
    assert_response :success
  end

  test "disallowed without ssl" do
    get :a
    assert_response :redirect
  end
end


class SslAllowedAllController < ActionController::Base
  include SslRequirement
  ssl_allowed :all

  def a
    render :nothing => true
  end
end

class SslAllowedAllTest < ActionController::TestCase
  def setup
    @controller = SslAllowedAllController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  test "allows ssl" do
    @request.env['HTTPS'] = "on"
    get :a
    assert_response :success
  end

  test "allowes without ssl" do
    get :a
    assert_response :success
  end
end


class SslAllowedAndRequiredController < ActionController::Base
  include SslRequirement
  ssl_allowed
  ssl_required

  def a
    render :nothing => true
  end
end

class SslAllowedAndRequiredTest < ActionController::TestCase
  def setup
    @controller = SslAllowedAndRequiredController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  test "allows ssl" do
    @request.env['HTTPS'] = "on"
    get :a
    assert_response :success
  end

  test "diallowes without ssl" do
    get :a
    assert_response :redirect
  end
end

class SslAllowedAndRequiredController < ActionController::Base
  include SslRequirement
  ssl_required

  def a
    render :nothing => true
  end

  protected

  def ssl_host
    'www.xxx.com'
  end
end

class SslHostTest < ActionController::TestCase
  def setup
    @controller = SslAllowedAndRequiredController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  test "uses ssl_host" do
    @request.env['HTTPS'] = "on"
    get :a
    assert_response :success
  end

  test "diallowes without ssl" do
    get :a
    assert_response :redirect
    assert_match %r{^https://www.xxx.com/}, @response.headers['Location']
  end
end

class SslAllowedWithExceptedMethods < ActionController::Base
  include SslRequirement
  ssl_allowed :except => [:non_secure_method]

  def secure
    render :nothing => true
  end

  def non_secure_method
    render :nothing => true
  end
end

class SslAllowedWithExceptedMethodsTest < ActionController::TestCase
  def setup
    @controller = SslAllowedWithExceptedMethods.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  test "uses ssl" do
    @request.env['HTTPS'] = "on"
    get :secure
    assert_response :success
  end

  test "diallowes with ssl on excluded methods" do
    @request.env['HTTPS'] = "on"
    get :non_secure_method
    assert_response :redirect
    assert_equal "http://test.host/ssl_allowed_with_excepted_methods/non_secure_method", @response.headers['Location']
  end
end

