# MediatypeDirectory

## DESCRIPTION

MediatypeDirectory enables you to create a directory of softlinks to all files of a specified media type (or types) in a directory tree.

## WHY?

I store content (text files, PDFs, HTML pages, office suite files, audio files, video files, etc.) mixed together in directory trees organized by subject. For example, the directory ~/Tech/Ruby/TESTING/RSpec may hold videos, HTML files, PDFs, podcasts, etc. all related to RSpec testing in Ruby.

But when I'm programming, I often want to quickly grab a PDF reference document without searching through the directory tree. I want softlinks to PDF files on Jasmine, RSpec, Rails, Ruby, Coffeescript, Underscore, JQuery, Javascript, Backbone, etc. all in one directory.

And when I have free time to watch videos, I'd like to quickly see the list of all available programming video files.

## REQUIREMENTS

I have run this only on Linux. It likely works on OS X. It may not work on Windows.

## BASIC USAGE

Create a new MediatypeDirectory object, passing in all your configuration options. Then tell the new object to .create_directory:

    require 'rubygems'

    config = {}
    config[:extensions]         = ['.mp4','mpeg4','mpg4']
    config[:mediatype_dirname]  = '~/path/to/dir/where/you/want/to/create/softlinks'
    config[:directory_tree]     = '~/path/to/top-level-dir/you/want/to/create/mediatype-directory/for'

    MediatypeDirectory.new(config).create_directory

## OPTIONS

## EXAMPLES

## LEGAL DISCLAIMER

Please use at your own risk. I guarantee nothing about this program.

