require "spec_helper"

describe Jobs::NotifyMailingListSubscribers do

  context "with mailing list on" do
    let(:user) { Fabricate(:user, mailing_list_mode: true) }

    context "with a valid post" do
      let!(:post) { Fabricate(:post, user: user) }

      it "sends the email to the user" do
        UserNotifications.expects(:mailing_list_notify).with(user, post).once
        Jobs::NotifyMailingListSubscribers.new.execute(post_id: post.id)
      end
    end

    context "with a deleted post" do
      let!(:post) { Fabricate(:post, user: user, deleted_at: Time.now) }

      it "doesn't send the email to the user" do
        UserNotifications.expects(:mailing_list_notify).with(user, post).never
        Jobs::NotifyMailingListSubscribers.new.execute(post_id: post.id)
      end
    end

    context "with a user_deleted post" do
      let!(:post) { Fabricate(:post, user: user, user_deleted: true) }

      it "doesn't send the email to the user" do
        UserNotifications.expects(:mailing_list_notify).with(user, post).never
        Jobs::NotifyMailingListSubscribers.new.execute(post_id: post.id)
      end
    end

    context "with a deleted topic" do
      let!(:post) { Fabricate(:post, user: user) }

      before do
        post.topic.update_column(:deleted_at, Time.now)
      end

      it "doesn't send the email to the user" do
        UserNotifications.expects(:mailing_list_notify).with(user, post).never
        Jobs::NotifyMailingListSubscribers.new.execute(post_id: post.id)
      end
    end

  end

  context "to an anonymous user with mailing list on" do
    let(:user) { Fabricate(:anonymous, mailing_list_mode: true) }
    let!(:post) { Fabricate(:post, user: user) }

    it "doesn't send the email to the user" do
      UserNotifications.expects(:mailing_list_notify).with(user, post).never
      Jobs::NotifyMailingListSubscribers.new.execute(post_id: post.id)
    end
  end

  context "with mailing list off" do
    let(:user) { Fabricate(:user, mailing_list_mode: false) }
    let!(:post) { Fabricate(:post, user: user) }

    it "doesn't send the email to the user" do
      UserNotifications.expects(:mailing_list_notify).never
      Jobs::NotifyMailingListSubscribers.new.execute(post_id: post.id)
    end
  end

end
