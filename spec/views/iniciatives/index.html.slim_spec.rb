require 'spec_helper'

describe "iniciatives/index" do
  before(:each) do
    assign(:iniciatives, [
      stub_model(Iniciative,
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
      ),
      stub_model(Iniciative,
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
      )
    ])
  end

  it "renders a list of iniciatives" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Department".to_s, :count => 2
    assert_select "tr>td", :text => "Municipality".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Zone".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Contact Name".to_s, :count => 2
    assert_select "tr>td", :text => "Contact Email".to_s, :count => 2
    assert_select "tr>td", :text => "Contact Phone".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
