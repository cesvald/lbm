require 'spec_helper'

describe "phases/index" do
  before(:each) do
    assign(:phases, [
      stub_model(Phase,
        :started_at => "",
        :title => "Title",
        :subtitle => "Subtitle",
        :description => "MyText",
        :channel => nil
      ),
      stub_model(Phase,
        :started_at => "",
        :title => "Title",
        :subtitle => "Subtitle",
        :description => "MyText",
        :channel => nil
      )
    ])
  end

  it "renders a list of phases" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Subtitle".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
