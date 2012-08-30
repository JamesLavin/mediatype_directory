require "spec_helper"
require_relative '../lib/mediatype_directory/mediatype_directory'

# Overriding FakeFS' File.expand_path
# because it delegates to the same class
# method in the REAL file system
module FakeFS
  class File
    def self.expand_path(*args)
      args[0].gsub(/~/,'/home/xavier')
    end
  end
  # Started overriding FileUtils.ln because FakeFS doesn't know about it
  # Instead switched to using File.link, which FakeFS knows about
end

# Overriding File.expand_path
# so it will provide the fake user's
# home directory
class File
  def self.expand_path(*args)
    args[0].gsub(/~/,'/home/xavier')
  end
end

describe MediatypeDirectory do

  subject { MediatypeDirectory.new(config) }

  let(:tilde_pdf_dir) { '~/my/pdf_dir' }
  let(:tilde_dir_tree) { '~/my/techfiles' }
  let(:exts) { ['.pdf','.odt'] }
  
  before do
    FileUtils.mkdir_p('/home/xavier/Tech2')
    FileUtils.mkdir_p('/home/xavier/Tech2/Ruby/TESTING')
    FileUtils.mkdir_p('/home/xavier/Tech2/JQuery')
    FileUtils.mkdir_p('/home/xavier/Tech2/XML')
    FileUtils.touch('/home/xavier/Tech2/Ruby/ruby.pdf')
    FileUtils.touch('/home/xavier/Tech2/Ruby/ruby.flv')
    FileUtils.touch('/home/xavier/Tech2/Ruby/TESTING/ruby_testing.pdf')
    FileUtils.touch('/home/xavier/Tech2/Ruby/TESTING/testing.mp3')
    FileUtils.touch('/home/xavier/Tech2/Ruby/TESTING/testing.mp4')
    FileUtils.touch('/home/xavier/Tech2/JQuery/jquery.pdf')
    FileUtils.touch('/home/xavier/Tech2/XML/xml.xml')
    Dir.chdir('/home/xavier/Tech2')
  end

  describe "test that FakeFS is properly configured" do
    specify { File.exists?('/home/xavier/Tech2/Ruby/ruby.pdf') }
    specify { Dir.exists?('/home/xavier/Tech2/JQuery') }
    specify { Dir.pwd == '/home/xavier/Tech2' }
    it "should find files using Dir.glob" do
      Dir.glob(File.join("/home/xavier/Tech2","**","*.pdf")).should == 
           ["/home/xavier/Tech2/JQuery/jquery.pdf", 
            "/home/xavier/Tech2/Ruby/TESTING/ruby_testing.pdf",
            "/home/xavier/Tech2/Ruby/ruby.pdf"]
    end
  end

  context "when config is empty hash" do

    let(:config) { {} }

    it { should be_true }
    it { should respond_to :create_directory }
  
    context "when setter sets mediatype_dirname" do

      before { subject.mediatype_dirname = tilde_pdf_dir }

      its(:mediatype_dirname) { should == Pathname.new(File.expand_path(tilde_pdf_dir)) }

    end

    context "when setter sets directory_tree" do

      before { subject.directory_tree = tilde_dir_tree }

      its(:directory_tree) { should == Pathname.new(File.expand_path(tilde_dir_tree)) }

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
    its(:mediatype_dirname) { should == Pathname.new(File.expand_path(tilde_pdf_dir)) }

  end

  context "when config sets test_mode as string 'true'" do

    let(:config) { { to: tilde_pdf_dir, from: tilde_dir_tree, test_mode: 'true' } }
  
    it { should be_true }
    its(:test_mode) { should be_true }

  end

  context "when config sets :source and :target" do

    let(:config) { { target: tilde_pdf_dir, source: tilde_dir_tree } }
  
    it { should be_true }
    its(:mediatype_dirname) { should == Pathname.new(File.expand_path(tilde_pdf_dir)) }
    its(:directory_tree) { should == Pathname.new(File.expand_path(tilde_dir_tree)) }

  end

  context "when config sets :from and :to" do

    let(:config) { { to: tilde_pdf_dir, from: tilde_dir_tree } }
  
    it { should be_true }
    its(:mediatype_dirname) { should == Pathname.new(File.expand_path(tilde_pdf_dir)) }
    its(:directory_tree) { should == Pathname.new(File.expand_path(tilde_dir_tree)) }

  end

  context "when config sets :what to 'ViDeO'" do

    let(:config) { { to: tilde_pdf_dir, from: tilde_dir_tree, what: 'ViDeO' } }
  
    it { should be_true }
    its(:extensions) { should include('.flv','.mov','.mp4','.ogv','.rm') }

  end

  context "when config sets :what to 'AuDiO'" do

    let(:config) { { to: tilde_pdf_dir, from: tilde_dir_tree, what: 'AuDiO' } }
  
    it { should be_true }
    its(:extensions) { should include('.dss','.flac','.mp3','.ogg','.ra') }

  end

  context "when config sets directory_tree" do

    let(:config) { { directory_tree: tilde_dir_tree } }
  
    it { should be_true }
    its(:directory_tree) { should == Pathname.new(File.expand_path(tilde_dir_tree)) }

  end

  context "when config sets extensions" do

    let(:config) { { extensions: exts } }
  
    it { should be_true }
    its(:extensions) { should == exts }

  end

  describe "#create_directory" do

    context "when values are set properly (with tildes)" do

      let(:config) { { mediatype_dirname: tilde_pdf_dir,
                       directory_tree: tilde_dir_tree,
                       extensions: exts } }

      it "should call :check directories and :create_links" do
        subject.should_receive(:check_directories)
        subject.should_receive(:create_links)
        subject.create_directory
      end

    end

    context "when values are set properly (with full paths)" do

      let(:xavier_docs_ruby) { '/home/xavier/Tech3/Docs/Ruby' }
      let(:xavier_ruby) { '/home/xavier/Tech2/Ruby' }
      let(:config) { { mediatype_dirname: xavier_docs_ruby,
                       directory_tree: xavier_ruby,
                       extensions: ['.pdf'],
                       linktype: 'hard' } }

      context "with test_mode = false" do

        it "should create the correct directory" do
          subject.create_directory
          Dir.exists?(xavier_docs_ruby).should be_true
        end

        it "should create the correct files" do
          subject.create_directory
          Dir.exists?('/home/xavier/Tech3/Docs/Ruby').should be_true
          Dir.glob(File.join("/home/xavier/Tech3","**","*.pdf")).should == 
              ["/home/xavier/Tech3/Docs/Ruby/ruby.pdf",
               "/home/xavier/Tech3/Docs/Ruby/ruby_testing.pdf"]
          File.exists?('/home/xavier/Tech3/Docs/Ruby/ruby_testing.pdf').should be_true
          File.exists?('/home/xavier/Tech3/Docs/Ruby/ruby.pdf').should be_true
          File.exists?('/home/xavier/Tech3/Docs/jquery.pdf').should be_false
          File.exists?('/home/xavier/Tech3/Docs/xml.xml').should be_false
        end

        context "with remove_old_links = true" do
        
          before do
            FileUtils.mkdir_p('/home/xavier/Tech3/Docs/Ruby')
            FileUtils.touch('/home/xavier/Tech3/Docs/Ruby/ruby_testing.pdf')
            FileUtils.touch('/home/xavier/Tech3/Docs/Ruby/ruby.pdf')
            File.exists?('/home/xavier/Tech3/Docs/Ruby/ruby_testing.pdf').should be_true
            File.exists?('/home/xavier/Tech3/Docs/Ruby/ruby.pdf').should be_true
            subject.remove_old_links = true
          end

          it "should remove old links" do
            subject.should_receive(:check_directories)
            subject.should_receive(:create_links)
            subject.create_directory
            File.exists?('/home/xavier/Tech3/Docs/Ruby/ruby_testing.pdf').should be_false
            File.exists?('/home/xavier/Tech3/Docs/Ruby/ruby.pdf').should be_false
          end

        end

      end

      context "with test_mode = true" do

        before { subject.test_mode = true }

        it "should not create the correct directory" do
          subject.create_directory
          Dir.exists?(xavier_docs_ruby).should be_false
        end

        it "should not create any files" do
          subject.create_directory
          Dir.exists?('/home/xavier/Tech3/Docs/Ruby').should be_false
          Dir.glob(File.join("/home/xavier/Tech3/Docs/Ruby","**","*.pdf")).should == []
          File.exists?('/home/xavier/Tech3/Docs/Ruby/ruby_testing.pdf').should be_false
          File.exists?('/home/xavier/Tech3/Docs/Ruby/ruby.pdf').should be_false
        end

        context "with remove_old_links = true" do
        
          before do
            FileUtils.mkdir_p('/home/xavier/Tech3/Docs/Ruby')
            FileUtils.touch('/home/xavier/Tech3/Docs/Ruby/ruby_testing.pdf')
            FileUtils.touch('/home/xavier/Tech3/Docs/Ruby/ruby.pdf')
            File.exists?('/home/xavier/Tech3/Docs/Ruby/ruby_testing.pdf').should be_true
            File.exists?('/home/xavier/Tech3/Docs/Ruby/ruby.pdf').should be_true
            subject.remove_old_links = true
          end

          it "should not remove old links" do
            subject.should_receive(:check_directories)
            subject.should_receive(:create_links)
            subject.create_directory
            File.exists?('/home/xavier/Tech3/Docs/Ruby/ruby_testing.pdf').should be_true
            File.exists?('/home/xavier/Tech3/Docs/Ruby/ruby.pdf').should be_true
          end

        end

      end

    end

    context "when mediatype_dirname & directory_tree are valid" do

      let(:config) { { mediatype_dirname: '/home/xavier/Tech3',
                       directory_tree: '/home/xavier/Tech2' } }
 
      it "throws InvalidDirname error" do
        expect { subject.create_directory }.to_not raise_error(MediatypeDirectory::InvalidDirname)
      end

    end

    context "when invalid mediatype_dirname" do

      let(:config) { { mediatype_dirname: 'not/valid/xavier/Tech3',
                       directory_tree: '/home/xavier/Tech2' } }
 
      it "throws InvalidDirname error" do
        expect { subject.create_directory }.to raise_error(MediatypeDirectory::InvalidDirname)
      end

    end

    context "when invalid directory_tree" do

      let(:config) { { mediatype_dirname: '/home/xavier/Tech3',
                       directory_tree: 'totally/invalid/xavier/Tech2' } }
 
      it "throws InvalidDirname error" do
        expect { subject.create_directory }.to raise_error(MediatypeDirectory::InvalidDirname)
      end

    end

  end

end
