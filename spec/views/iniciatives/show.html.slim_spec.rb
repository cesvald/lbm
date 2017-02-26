require 'spec_helper'

describe "iniciatives/show" do
  before(:each) do
    @iniciative = assign(:iniciative, stub_model(Iniciative,
      :name => "Name",
      :category => nil,
      :description => "MyText",
      :year => 1,
      :activities => "MyText",
      :department => "Department",
      :municipality => "Municipality",
      :other_municipality => "MyText",
      :participants_count => 2,
      :zone => "Zone",
      :women_count => 3,
      :average_age => 4,
      :benefited_count => 5,
      :web_url => "MyText",
      :facebook_url => "MyText",
      :blog_url => "MyText",
      :video_url => "MyText",
      :contact_name => "Contact Name",
      :contact_email => "Contact Email",
      :contact_phone => "Contact Phone",
      :financial_channel => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(//)
    rendered.should match(/MyText/)
    rendered.should match(/1/)
    rendered.should match(/MyText/)
    rendered.should match(/Department/)
    rendered.should match(/Municipality/)
    rendered.should match(/MyText/)
    rendered.should match(/2/)
    rendered.should match(/Zone/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/Contact Name/)
    rendered.should match(/Contact Email/)
    rendered.should match(/Contact Phone/)
    rendered.should match(//)
  end
end
