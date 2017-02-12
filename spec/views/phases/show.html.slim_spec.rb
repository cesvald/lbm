require 'spec_helper'

describe "phases/show" do
  before(:each) do
    @phase = assign(:phase, stub_model(Phase,
      :started_at => "",
      :title => "Title",
      :subtitle => "Subtitle",
      :description => "MyText",
      :channel => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(/Title/)
    rendered.should match(/Subtitle/)
    rendered.should match(/MyText/)
    rendered.should match(//)
  end
end
