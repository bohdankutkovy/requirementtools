require 'spec_helper'

RSpec.describe WelcomeController, type: :controller do

  it "renders the index template" do
    get :index
    expect(response).to render_tempalte("index")
  end

end