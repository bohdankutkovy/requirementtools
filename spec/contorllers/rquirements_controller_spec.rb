require 'spec_helper'

RSpec.describe RequirementsController, type: :controller do
  it 'includes UrlHelper && RequirementsHelper module' do
    expect(subject.class).to receive(:include).with(RequirementsHelper)
    expect(subject.class).to receive(:include).with(ActionView::Helpers::UrlHelper)
    load File.join(Rails.root, 'app/controllers/requirements_controller.rb')
  end

  it 'includes sign_in filter' do

  end



end