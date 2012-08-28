# MediatypeDirectory

## DESCRIPTION

MediatypeDirectory enables you to create a directory of (soft or hard) links to all files of a specified media type (or types) in a directory tree.

## WHY?

I store content (text files, PDFs, HTML pages, office suite files, audio files, video files, etc.) mixed together in directory trees organized by subject. For example, the directory ~/Tech/Ruby/TESTING/RSpec may hold videos, HTML files, PDFs, podcasts, etc. all related to RSpec testing in Ruby.

But when I'm programming, I often want to quickly grab a PDF reference document without searching through the directory tree. I want links to PDF files on Jasmine, RSpec, Rails, Ruby, Coffeescript, Underscore, JQuery, Javascript, Backbone, etc. all in one directory.

And when I have free time to watch videos, I'd like to quickly see the list of all available programming video files.

## REQUIREMENTS

I've run this only on Linux. It likely works on OS X. It probably won't work on Windows.

## BASIC USAGE

Create a new MediatypeDirectory object, passing in all your configuration options (or setting them on the object via setters). Then tell the new object to .create_directory:

    require 'rubygems'

    config = {}
    config[:extensions]         = ['.flv','.mov','.mpg','.mp4']
    config[:mediatype_dirname]  = '~/path/to/dir/where/you/want/to/create/links'
    config[:directory_tree]     = '~/path/to/top-level-dir/you/want/to/create/mediatype-directory/for'
    config[:linktype]           = 'hard'  # default: 'soft'

    MediatypeDirectory.new(config).create_directory

## OPTIONS

## EXAMPLE

    require 'mediatype_directory'

    md = MediatypeDirectory.new({
          extensions: [".flv",".mov",".mpg",'.mp4'],
          directory_tree: '/home/jimmy/Tech/Ruby',     # Where to look for existing files
          mediatype_dirname: '~/Tech/Docs2/Videos',    # Where to store links to existing files
          linktype: 'hard'
        })

    md.create_directory

## LEGAL DISCLAIMER

Please use at your own risk. I guarantee nothing about this program.

