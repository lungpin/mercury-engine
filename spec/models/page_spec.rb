require 'spec_helper'

describe Page do
  context "with hierarchy" do
    let!(:root)    { create_page(permalink: 'home') }
    let!(:about)   { create_page(permalink: 'about', parent: root) }
    let!(:company) { create_page(permalink: 'company', parent: about) }
    let(:services) { create_page(permalink: 'services', parent: company) }

    context 'path' do
      specify { root.path.should == '/'}
      specify { about.path.should == '/about' }
      specify { company.path.should == '/about/company' }
      specify { services.path.should == '/about/company/services' }
    end

    context '#find_by_path' do
      context "found" do
        specify("root")                  { Page.find_by_path("").should == root }
        specify("root with slash")       { Page.find_by_path("/").should == root }
        specify("root with nil")         { Page.find_by_path(nil).should == root }
        specify("child")                 { Page.find_by_path("about").should == about }
        specify("child with slash")      { Page.find_by_path("/about").should == about }
        specify("grandchild")            { Page.find_by_path("about/company").should == company }
        specify("grandchild with slash") { Page.find_by_path("/about/company").should == company }
      end

      context "not found" do
        specify { Page.find_by_path('page-not-found').should be_nil }
      end
    end
  end

  context "#update_content" do
    context "root found" do
      let!(:root) { create_page(permalink: 'home') }

      specify('url empty')    { Page.update_content("").should == root }
      specify('url is slash') { Page.update_content("/").should == root }
      specify('url is nil')   { Page.update_content(nil).should == root }
    end

    context "root no found" do
      specify('url empty')    { Page.update_content("").path.should == "/" }
      specify('url is slash') { Page.update_content("/").path.should == "/" }
      specify('url is nil')   { Page.update_content(nil).path.should == "/" }
    end

    context "child page found" do
      let!(:root)  { create_page(permalink: 'home') }
      let!(:about) { create_page(permalink: 'about', parent: root) }

      specify               { Page.update_content("about").should == about }
      specify("with slash") { Page.update_content("/about").should == about }
    end

    context "child page not found" do
      context "root found" do
        let!(:root) { create_page(permalink: 'home') }

        specify               { Page.update_content("about").parent.should == root }
        specify               { Page.update_content("about").path.should   == '/about' }
        specify("with slash") { Page.update_content("/about").path.should  == '/about' }
      end

      context "root not found" do
        specify               { Page.update_content("about").path.should  == '/about' }
        specify("with slash") { Page.update_content("/about").path.should == '/about' }
      end
    end

    context "grandchild page found" do
      let!(:root)           { create_page(permalink: 'home') }
      let!(:about)          { create_page(permalink: 'about', parent: root) }
      let!(:company)        { create_page(permalink: 'company', parent: about) }

      specify               { Page.update_content("about/company").parent.should == about }
      specify               { Page.update_content("about/company").should        == company }
      specify("with slash") { Page.update_content("/about/company").should       == company }
    end

    context "grandchild page not found" do
      specify               { Page.update_content("about/company").path.should  == '/about/company' }
      specify("with slash") { Page.update_content("/about/company").path.should == '/about/company' }
    end
  end

  def create_page(attrs = {})
    default_attrs = {}
    Page.create(default_attrs.merge(attrs))
  end
end
