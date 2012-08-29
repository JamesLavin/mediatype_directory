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
# md.extensions        = ['.pdf','.odt']
# md.mediatype_dirname = '~/Tech/Docs/PDFs'
# md.directory_tree    = '~/Tech'
# md.create_directory
#
class MediatypeDirectory

  attr_accessor :extensions, :linktype, :test_mode
  attr_reader :mediatype_dirname, :directory_tree

  class InvalidDirname < StandardError
  end

  def initialize(config)
    self.extensions         = config[:extensions]
    self.mediatype_dirname  = config[:mediatype_dirname] || config[:target] || config[:to]
    self.directory_tree     = config[:directory_tree] || config[:source] || config[:from]
    self.linktype           = config[:linktype] || 'soft'
    self.test_mode          = config[:test_mode] || false
  end

  def create_directory
    check_directories
    create_links
  end

  def mediatype_dirname=(dirname)
    @mediatype_dirname = nil_or_convert_dirname(dirname)
  end

  def directory_tree=(dirname)
    @directory_tree = nil_or_convert_dirname(dirname)
  end

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
    #puts "Found these files: " + @mediatype_files.to_s
    mediatype_files_to_links
  end

  # returns array of file pathnames in the directory_tree
  # matching one of the file extensions
  def get_all_mediatype_files
    puts "Searching for files in #{directory_tree}"
    Dir.chdir(directory_tree)
    mediatype_files = []
    @extensions.each do |ex|
      search_for = File.join("**", '*' + ex)        # example: "**/*.pdf"
      mediatype_files.concat(Dir.glob(search_for))
    end
    puts "Found these files: " + mediatype_files.to_s
    convert_to_pathnames(mediatype_files).delete_if { |mf| mf.dirname.to_s == @mediatype_dirname }
  end

  def convert_to_pathnames(filenames)
    filenames.map { |mf| Pathname.new(mf).realdirpath }
  end

  def mediatype_files_to_links
    Dir.chdir(mediatype_dirname) unless test_mode
    @mediatype_files.each do |pathname|
      mediatype_file_to_link pathname
    end
  end

  def mediatype_file_to_link(pathname)
    puts "Attempting to create link for #{pathname.to_s}"
    link = source_pathname_to_target_pathname(pathname)
    if File.exists?(link.to_s)
      puts "WARNING: #{link.to_s} already exists"
    else
      puts "Creating #{link.to_s}"
      (hardlinks? ? FileUtils.ln(pathname.to_s, link.to_s) : FileUtils.ln_s(pathname.to_s, link.to_s)) unless test_mode
    end
  end

  def source_pathname_to_target_pathname(source_pathname)
    Pathname.new(mediatype_dirname) + source_pathname.basename
  end

  def nil_or_convert_dirname(dirname)
    (dirname.nil? || dirname == '') ? nil : convert_dirname(dirname)
  end

  def check_directories
    validate_directories
    create_missing_directories
  end

  def create_missing_directories
    [mediatype_dirname, directory_tree].each do|dn|
      make_dirname(dn)
    end
  end

  def validate_directories
    [mediatype_dirname, directory_tree].each do|dn|
      validate_dirname(dn)
    end
  end

  def make_dirname(dn)
    unless File.directory? dn
      puts "Creating directory #{dn}"
      FileUtils.mkdir_p(dn) unless test_mode
    end
  end

  # Ideally, should use a regexp that matches valid directories
  # For now, a simple sanity check
  def validate_dirname(dirname)
    raise MediatypeDirectory::InvalidDirname, "#{dirname} is not a valid directory name" if dirname.match(/\s/) || !dirname.match(/^\//)
  end

  def convert_dirname(dirname)
    File.expand_path(dirname)
  end

end
