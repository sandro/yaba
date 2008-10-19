require File.dirname(__FILE__) + '/../spec_helper'

class TestController < ApplicationController
  include LoginActions
end

describe LoginActions do
  # TODO - make this a controller test by testing testcontroller not the module directly
  before :each do
    @user = stub_model(User)
    @login = stub_model(UserLogin)
    @controller = TestController.new
    @controller.stub!(:session).and_return({})
    @controller.instance_variable_set(:@user_login, @login)
  end

  describe "successful login for user" do
    it 'should set the current user' do
      @controller.should_receive(:current_user=).with(@user)
      @controller.send :successful_login_for, @user
    end

    it 'should inform the user that login was successful' do
      @controller.stub!(:current_user=)
      @controller.send :successful_login_for, @user
      flash[:notice].should_not be_nil
    end

    describe 'remembering the user' do
      it 'should remember the user' do
        @login.stub!(:wants_to_be_remembered?).and_return(true)
        @controller.should_receive(:handle_remember_cookie!).with(true)
        @controller.send :successful_login_for, @user
      end

      it 'should not remember the user' do
        @login.stub!(:wants_to_be_remembered?).and_return(false)
        @controller.should_receive(:handle_remember_cookie!).with(false)
        @controller.send :successful_login_for, @user
      end
    end
  end

  def flash
    @controller.send(:flash)
  end
end
