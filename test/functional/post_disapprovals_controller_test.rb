require 'test_helper'

class PostDisapprovalsControllerTest < ActionDispatch::IntegrationTest
  context "The post disapprovals controller" do
    setup do
      @approver = create(:approver)
      @post = create(:post, is_pending: true)
      @post_disapproval = create(:post_disapproval, post: @post)
    end

    context "create action" do
      should "render" do
        assert_difference("PostDisapproval.count", 1) do
          post_auth post_disapprovals_path, @approver, params: { post_disapproval: { post_id: @post.id, reason: "breaks_rules" }, format: "js" }
          assert_response :success
        end
      end

      should "render for json" do
        assert_difference("PostDisapproval.count", 1) do
          post_auth post_disapprovals_path, @approver, params: { post_disapproval: { post_id: @post.id, reason: "breaks_rules" }, format: "json" }
          assert_response :success
        end
      end

      should "not allow non-approvers to create disapprovals" do
        assert_difference("PostDisapproval.count", 0) do
          post_auth post_disapprovals_path, create(:user), params: { post_disapproval: { post_id: @post.id, reason: "breaks_rules" }, format: "json" }
          assert_response 403
        end
      end
    end

    context "index action" do
      should "allow mods to see disapprover names" do
        get_auth post_disapprovals_path, create(:mod_user)
        assert_response :success
        assert_select "tr#post-disapproval-#{@post_disapproval.id} .created-column a.user-member", true
      end

      should "not allow non-mods to see disapprover names" do
        get post_disapprovals_path
        assert_response :success
        assert_select "tr#post-disapproval-#{@post_disapproval.id} .created-column a.user-member", false
      end
    end
  end
end
