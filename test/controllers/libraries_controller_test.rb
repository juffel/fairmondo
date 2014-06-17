#
#
# == License:
# Fairnopoly - Fairnopoly is an open-source online marketplace.
# Copyright (C) 2013 Fairnopoly eG
#
# This file is part of Fairnopoly.
#
# Fairnopoly is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Fairnopoly is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Fairnopoly.  If not, see <http://www.gnu.org/licenses/>.
#
require 'test_helper'

describe LibrariesController do

  describe "GET 'index" do
    describe "for non-signed-in users" do
      before :each do
        @user = FactoryGirl.create(:user)
      end

      it "should allow access" do
        get :index, :user_id => @user.id
        assert_response :success
      end
    end

    describe "for signed-in users" do
      before :each do
        @library = FactoryGirl.create(:library)

        sign_in @library.user
      end

      it "should be successful" do
        get :index, :user_id => @library.user
        assert_response :success
      end

      it "should be successful" do
        get :show, :user_id => @library.user, :id => @library.id
        assert_response :success
      end
    end

    describe '::focus' do
      it 'should return Library if no user is focused' do
        @controller.stubs(:user_focused?).returns(false)
        assert_equal(Library, @controller.send(:focus))
      end
    end
  end
end