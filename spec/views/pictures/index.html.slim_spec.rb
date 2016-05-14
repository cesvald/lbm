# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "pictures/index" do
  before(:each) do
    assign(:pictures, [
      stub_model(Picture,
        :project_id => 1,
        :picture => "Picture"
      ),
      stub_model(Picture,
        :project_id => 1,
        :picture => "Picture"
      )
    ])
  end

  it "renders a list of pictures" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Picture".to_s, :count => 2
  end
end
