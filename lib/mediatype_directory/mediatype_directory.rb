require 'rubygems'
require 'fileutils'
require 'pathname'

# MediatypeDirectory.new takes a configuration hash and creates an object with a create_directory() method
# Calling create_directory() on the MediatypeDirectory object creates a directory, configured according to 
# the configuration hash settings, containing softlinks to all files of the requested file extension(s) in
# the specified directory tree.
#
# Usage:
# MediatypeDirectory.new(options_hash).create_directory
#
# Alternative usage:
# md = MediatypeDirectory.new
# md.property = value (for all desired property-value pairs)
# md.create_directory
#
# Example:
# To create a directory at '~/Tech/Docs/PDFs' with softlinks to all PDF and ODT files under '~/Tech':
# md = MediatypeDirectory.new
# md.extensions        = ['.pdf','.odt']     # or: md.what = '.doc'
# md.mediatype_dirname = '~/Tech/Docs/PDFs'  # or: md.to   = '~/Tech/Docs/PDFs'
# md.directory_tree    = '~/Tech'            # or: md.from = '~/Tech'
# md.create_directory
#
# (If you run the program multiple times, it will NOT make links to anything in the mediatype_dirname dir)
#
class MediatypeDirectory

  require "mediatype_directory/file_extensions"

  attr_accessor :extensions, :linktype
  attr_reader :mediatype_dirname, :directory_tree, :test_mode, :mediatype_files, :remove_old_links

  class InvalidDirname < StandardError
  end

  # delete all files named #{filename} under the directory tree #{dirname}
  def self.delete_all(filename, dirname, test = false)
    return unless dirname = File.expand_path(dirname)
    to_be_deleted = Dir.glob(dirname + "/**/" + filename)
    if test
      to_be_deleted.each { |to_d| puts "Would delete #{to_d}" }
    else
      to_be_deleted.each do |to_d|
        puts "Deleting #{to_d}"
        File.delete(to_d)
      end
    end
  end

  def initialize(config)
    self.extensions         = config[:extensions] || config[:what]
    self.mediatype_dirname  = config[:mediatype_dirname] || config[:target] || config[:to]
    self.directory_tree     = config[:directory_tree] || config[:source] || config[:from]
    self.linktype           = config[:linktype] || 'soft'
    self.test_mode          = config[:test_mode] || false
    self.remove_old_links   = config[:remove_old_links] || false
  end

  def create_directory
    check_directories
    delete_old_links if remove_old_links
    create_links
  end

  def mediatype_dirname=(dirname)
    @mediatype_dirname = nil_or_convert_dirname(dirname)
  end

  def directory_tree=(dirname)
    @directory_tree = nil_or_convert_dirname(dirname)
  end

  def extensions=(exts)
    @extensions = if exts =~ /video/i
                    FileExtensions::VIDEO_FILE_EXTENSIONS
                  elsif exts =~ /audio/i
                    FileExtensions::AUDIO_FILE_EXTENSIONS
                  else
                    Array(exts)
                  end
  end

  def test_mode=(val)
    @test_mode = (val == true || val == 'true')
  end

  def remove_old_links=(val)
    @remove_old_links = (val == true || val == 'true')
  end

  alias_method :what, :extensions
  alias_method :what=, :extensions=
  alias_method :source, :directory_tree
  alias_method :from, :directory_tree
  alias_method :source=, :directory_tree=
  alias_method :from=, :directory_tree=
  alias_method :target, :mediatype_dirname
  alias_method :to, :mediatype_dirname
  alias_method :target=, :mediatype_dirname=
  alias_method :to=, :mediatype_dirname=

  private

  def hardlinks?
    @linktype == 'hard'
  end

  def create_links
    @mediatype_files = get_all_mediatype_files
    #puts "Found these files: " + mediatype_files.to_s
    mediatype_files_to_links
  end

  # returns array of file pathnames in the directory_tree
  # matching one of the file extensions
  def get_all_mediatype_files
    puts "Searching for files in #{directory_tree}"
    # Rewrote to use absolute search paths because FakeFS chokes on Dir.chdir
    matching_files = []
    @extensions.each do |ex|
      search_for = File.join(directory_tree, "**", '*' + ex)        # example: "/home/xavier/Tech/Docs/**/*.pdf"
      matching_files.concat(Dir.glob(search_for))
    end
    #puts "Found these files: " + matching_files.to_s
    convert_to_pathnames(matching_files).delete_if { |file| file.dirname.to_s == mediatype_dirname.to_s }
  end

  def convert_to_pathnames(path_string_array)
    path_string_array.map { |path_string| Pathname.new(path_string) }
  end

  def mediatype_files_to_links
    mediatype_files.each do |pathname|
      mediatype_file_to_link pathname
    end
  end

  # In test_mode with delete_old_links, we want to pretend the links
  # have been deleted, even though we're not actually deleting them
  def pretend_links_do_not_exist
    test_mode && remove_old_links
  end

  def mediatype_file_to_link(pathname)
    puts "Attempting to create link for #{pathname.to_s}"
    link = source_pathname_to_target_pathname(pathname)
    if File.exists?(link.to_s)  && !pretend_links_do_not_exist
      puts "WARNING: #{link.to_s} already exists"
    else
      puts "Creating #{link.to_s}"
      # Switched from File.link to FileUtils.ln because FakeFS doesn't know FileUtils.ln but knows File.link
      (hardlinks? ? File.link(pathname.to_s, link.to_s) : FileUtils.ln_s(pathname.to_s, link.to_s)) unless test_mode
    end
  end

  def source_pathname_to_target_pathname(source_pathname)
    #Pathname.new(mediatype_dirname) + source_pathname.basename
    mediatype_dirname + source_pathname.basename
  end

  def nil_or_convert_dirname(dirname)
    (dirname.nil? || dirname == '') ? nil : Pathname.new(File.expand_path(dirname))
  end

  def check_directories
    validate_directories
    create_missing_directories
  end

  def create_missing_directories
    [mediatype_dirname, directory_tree].each do|dn|
      make_dirname(dn.to_s)
    end
  end

  def validate_directories
    [mediatype_dirname, directory_tree].each do|dn|
      validate_dirname(dn)
    end
  end

  def make_dirname(dn_string)
    unless File.directory? dn_string
      puts "Creating directory #{dn_string}"
      FileUtils.mkdir_p(dn_string) unless test_mode
    end
  end

  # Ideally, should use a regexp that matches valid directories
  # For now, a simple sanity check
  def validate_dirname(dirname)
    unless dirname.to_s.match(/^\//)
      raise MediatypeDirectory::InvalidDirname, "#{dirname.to_s} is not a valid directory name"
    end
  end

  def delete_old_links
    old_links.each do |ol|
      puts "Deleting file #{ol}"
      File.unlink(ol) unless test_mode
    end
  end

  def old_links
    old_links = []
    @extensions.each do |ex|
      search_for = File.join(mediatype_dirname, "**", '*' + ex)        # example: "/home/xavier/Tech/Docs/**/*.pdf"
      old_links.concat(Dir.glob(search_for))
    end
    old_links
  end

end
