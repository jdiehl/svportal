require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/assignments_controller'

# Re-raise errors caught by the controller.
class Admin::AssignmentsController; def rescue_action(e) raise e end; end

class Admin::AssignmentsControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::AssignmentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
