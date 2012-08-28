require "spec_helper"
require_relative '../lib/mediatype_directory/mediatype_directory'
#require 'fakefs'

# Overriding FakeFS' File.expand_path
# because it delegates to the same class
# method in the REAL file system
module FakeFS
  class File
    def self.expand_path(*args)
      args[0].gsub(/~/,'/home/xavier')
    end
  end
end

describe MediatypeDirectory do

  subject { MediatypeDirectory.new(config) }

  let(:tilde_pdf_dir) { '~/my/pdf_dir' }
  let(:tilde_dir_tree) { '~/my/techfiles' }
  let(:exts) { ['.pdf','.odt'] }
  
  before do
    #Dir.new('/home/xavier')
    FileUtils.mkdir_p('/home/xavier/Tech2')
    FileUtils.mkdir_p('/home/xavier/Ruby')
    FileUtils.mkdir_p('/home/xavier/Tech2/Ruby/TESTING')
    FileUtils.mkdir_p('/home/xavier/Tech2/JQuery')
    FileUtils.mkdir_p('/home/xavier/Tech2/XML')
    FileUtils.touch('/home/xavier/Tech2/Ruby/ruby.pdf')
    FileUtils.touch('/home/xavier/Tech2/Ruby/TESTING/ruby_testing.pdf')
    FileUtils.touch('/home/xavier/Tech2/JQuery/jquery.pdf')
    FileUtils.touch('/home/xavier/Tech2/XML/xml.xml')
    Dir.chdir('/home/xavier/Tech2')
  end

  describe "test that FakeFS is properly configured" do
    specify { File.exists?('/home/xavier/Tech2/Ruby/ruby.pdf') }
    specify { Dir.exists?('/home/xavier/Tech2/JQuery') }
    specify { Dir.pwd == '/home/xavier/Tech2' }
  end

  context "when config is empty hash" do

    let(:config) { {} }

    it { should be_true }
    it { should respond_to :create_directory }
  
    context "when setter sets mediatype_dirname" do

      before { subject.mediatype_dirname = tilde_pdf_dir }

      its(:mediatype_dirname) { should == File.expand_path(tilde_pdf_dir) }

    end

    context "when setter sets directory_tree" do

      before { subject.directory_tree = tilde_dir_tree }

      its(:directory_tree) { should == File.expand_path(tilde_dir_tree) }

    end

    context "when setter sets extensions" do

      before do
        subject.extensions = exts
      end

      its(:extensions) { should == exts }

    end

  end

  context "when config sets mediatype_dirname" do

    let(:config) { { mediatype_dirname: tilde_pdf_dir } }
  
    it { should be_true }
    
    #it "should set mediatype_dirname correctly" do
    specify { subject.mediatype_dirname.should == File.expand_path(tilde_pdf_dir) }
    #its(:mediatype_dirname) { should == File.expand_path(tilde_pdf_dir) }
    #end

  end

  context "when config sets directory_tree" do

    let(:config) { { directory_tree: tilde_dir_tree } }
  
    it { should be_true }
    its(:directory_tree) { should == File.expand_path(tilde_dir_tree) }

  end

  context "when config sets extensions" do

    let(:config) { { extensions: exts } }
  
    it { should be_true }
    its(:extensions) { should == exts }

  end

  describe "#create_directory" do

    context "when values are set properly" do

      let(:config) { { mediatype_dirname: tilde_pdf_dir,
                       directory_tree: tilde_dir_tree,
                       extensions: exts } }

      it "should check dirs, and create softlinks" do
        #Dir.stub(:chdir)
        subject.should_receive(:check_directories)
        Dir.should_receive(:chdir)
        subject.should_receive(:create_softlinks)
        subject.create_directory
      end

    end

    context "when invalid mediatype_dirname" do

      let(:config) { { mediatype_dirname: '~/techfiles/ /pd fs' } }
 
      it "throws InvalidDirname error" do
        expect { subject.create_directory }.to raise_error(MediatypeDirectory::InvalidDirname)
      end

    end

  end

end