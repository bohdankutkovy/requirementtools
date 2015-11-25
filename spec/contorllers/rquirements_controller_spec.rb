require 'spec_helper'

RSpec.describe RequirementsController, type: :controller do
  it 'includes UrlHelper && RequirementsHelper module' do
    expect(subject.class).to receive(:include).with(RequirementsHelper)
    expect(subject.class).to receive(:include).with(ActionView::Helpers::UrlHelper)
    load File.join(Rails.root, 'app/controllers/requirements_controller.rb')
  end

  it 'includes sign_in && entry_accessed filters' do
    RequirementsController.should_receive(:before_filter).with(:ensure_user_is_signed_in?)
    RequirementsController.should_receive(:before_filter).with(:entry_accessed?)
    load File.join(Rails.root, 'app/controllers/requirements_controller.rb')
  end



end