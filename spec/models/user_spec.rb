# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  before :each do
    @user = User.new(name: 'tom', email: 'tom@gmail.com', password: '123456', password_confirmation: '123456')
  end

  it 'is valid user' do
    expect(@user).to be_valid
  end

  it 'is not a valid email' do
    @user.email = 'tomgmail.com'
    expect(@user).to_not be_valid
  end
end
