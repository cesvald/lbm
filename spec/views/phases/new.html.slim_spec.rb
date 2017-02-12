require 'spec_helper'

describe "phases/new" do
  before(:each) do
    assign(:phase, stub_model(Phase,
      :started_at => "",
      :title => "MyString",
      :subtitle => "MyString",
      :description => "MyText",
      :channel => nil
    ).as_new_record)
  end

  it "renders new phase form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", phases_path, "post" do
      assert_select "input#phase_started_at[name=?]", "phase[started_at]"
      assert_select "input#phase_title[name=?]", "phase[title]"
      assert_select "input#phase_subtitle[name=?]", "phase[subtitle]"
      assert_select "textarea#phase_description[name=?]", "phase[description]"
      assert_select "input#phase_channel[name=?]", "phase[channel]"
    end
  end
end
