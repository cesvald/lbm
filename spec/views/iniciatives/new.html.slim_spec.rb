require 'spec_helper'

describe "iniciatives/new" do
  before(:each) do
    assign(:iniciative, stub_model(Iniciative,
      :name => "MyString",
      :category => nil,
      :description => "MyText",
      :year => 1,
      :activities => "MyText",
      :department => "MyString",
      :municipality => "MyString",
      :other_municipality => "MyText",
      :participants_count => 1,
      :zone => "MyString",
      :women_count => 1,
      :average_age => 1,
      :benefited_count => 1,
      :web_url => "MyText",
      :facebook_url => "MyText",
      :blog_url => "MyText",
      :video_url => "MyText",
      :contact_name => "MyString",
      :contact_email => "MyString",
      :contact_phone => "MyString",
      :financial_channel => nil
    ).as_new_record)
  end

  it "renders new iniciative form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", iniciatives_path, "post" do
      assert_select "input#iniciative_name[name=?]", "iniciative[name]"
      assert_select "input#iniciative_category[name=?]", "iniciative[category]"
      assert_select "textarea#iniciative_description[name=?]", "iniciative[description]"
      assert_select "input#iniciative_year[name=?]", "iniciative[year]"
      assert_select "textarea#iniciative_activities[name=?]", "iniciative[activities]"
      assert_select "input#iniciative_department[name=?]", "iniciative[department]"
      assert_select "input#iniciative_municipality[name=?]", "iniciative[municipality]"
      assert_select "textarea#iniciative_other_municipality[name=?]", "iniciative[other_municipality]"
      assert_select "input#iniciative_participants_count[name=?]", "iniciative[participants_count]"
      assert_select "input#iniciative_zone[name=?]", "iniciative[zone]"
      assert_select "input#iniciative_women_count[name=?]", "iniciative[women_count]"
      assert_select "input#iniciative_average_age[name=?]", "iniciative[average_age]"
      assert_select "input#iniciative_benefited_count[name=?]", "iniciative[benefited_count]"
      assert_select "textarea#iniciative_web_url[name=?]", "iniciative[web_url]"
      assert_select "textarea#iniciative_facebook_url[name=?]", "iniciative[facebook_url]"
      assert_select "textarea#iniciative_blog_url[name=?]", "iniciative[blog_url]"
      assert_select "textarea#iniciative_video_url[name=?]", "iniciative[video_url]"
      assert_select "input#iniciative_contact_name[name=?]", "iniciative[contact_name]"
      assert_select "input#iniciative_contact_email[name=?]", "iniciative[contact_email]"
      assert_select "input#iniciative_contact_phone[name=?]", "iniciative[contact_phone]"
      assert_select "input#iniciative_financial_channel[name=?]", "iniciative[financial_channel]"
    end
  end
end
