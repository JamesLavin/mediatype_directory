# MediatypeDirectory

## DESCRIPTION

MediatypeDirectory lets Linux/Mac users create a directory of (soft or hard) links to all files of a specified media type (or types) in a directory tree.

## WHY?

I store content (text files, PDFs, HTML pages, office suite files, audio files, video files, etc.) mixed together in directory trees organized by subject. For example, the directory ~/Tech/Ruby/TESTING/RSpec may hold videos, HTML files, PDFs, podcasts, etc. all related to RSpec testing in Ruby.

But when I'm programming, I often want to quickly grab a PDF reference document without searching through the directory tree. I want links to PDF files on Jasmine, RSpec, Rails, Ruby, Coffeescript, Underscore, JQuery, Javascript, Backbone, etc. all in one directory.

And when I have free time to watch videos, I'd like to quickly see the list of all available programming video files.

## REQUIREMENTS

I've run this only on Linux. It likely works on OS X. It probably won't work on Windows.

## BASIC USAGE

Create a new MediatypeDirectory object, passing in all your configuration options (or setting them on the object via setters). Then tell the new object to .create_directory:

    require 'mediatype_directory'

    config = {}
    config[:what]       = '.pdf'    # OR an array like ['.htm','.html','.shtml'] OR or a special string, 'audio' or 'video'
    config[:from]       = '~/path/to/top-level-dir/where/your/files/are'
    config[:to]         = '~/path/to/dir/where/you/want/to/create/links'
    config[:linktype]   = 'hard'    # default: 'soft'
    config[:test_mode]  = true      # (or 'true', default: false)   In test_mode, no directories or files are actually created and no old links are removed
    config[:remove_old_links]  = true   # (or 'true', default: false)  If true, all existing links in the link directory are deleted before creating new links

    MediatypeDirectory.new(config).create_directory

config[:what] has an alias, config[:extensions]. You can also call "md.extensions = " or "md.what = "

config[:from] has aliases config[:source] & config[:directory_tree]. You can also call "md.source =", "md.from = " or "md.directory_tree ="

config[:to] has aliases config[:target] & config[:mediatype_dirname]. You can also call "md.target =", "md.to = " or "md.mediatype_dirname ="

It's safe to re-run this program as many times as you want. If a link already exists, it will be skipped (unless you set :remove_old_links = true). But if a new file is found that matches the criteria, a new link will be added.

If the original content of a hard link changes, the hard link will continue referring to the original version. You can delete the hard link (which should remove the old version from your system) and regenerate a new hardlink, which should point to the new version.

## DELETING A FILE WITH MULTIPLE LINKS

After you create link directories, deleting files becomes a hassle because you must track down ALL file references. So we make this a bit easier.

To delete all links to a filename under a directory_tree:

    require 'mediatype_directory'

    MediatypeDirectory.delete_all 'file_I_want_to_delete.mp4', '~/path/to/top/of/directory_tree'

To see the files that would be deleted without deleting any (i.e., test mode), change the above to:

    MediatypeDirectory.delete_all 'file_I_want_to_delete.mp4', '~/path/to/top/of/directory_tree', true

(We will also provide this as a command-line option.)

## EXAMPLE

    require 'mediatype_directory'

    md = MediatypeDirectory.new({
          what: [".flv",".mov",".mpg",'.mp4'],        # List of file extensions for which you wish to generate links
          from: '/home/jimmy/Tech/Ruby',              # Where to look for existing files
          to: '~/Tech/Docs2/Videos',                  # Where to store links to existing files
          linktype: 'hard',                           # Create hard links, not soft links (a.k.a. symbolic links)
          test_mode: true                             # Show what would happen without actually creating directories or files
        })

    md.create_directory

## COMING ATTRACTIONS (I HOPE)

* More special strings, like 'photos'

* Easy way to create combinations of :what and :from. For example, you might want to create ['~/Tech/Docs/PDFs', '~/Tech/Docs/Audio', '~/Tech/Docs/Video'] for each of five directory trees, ['~/Tech/Javascript', '~/Tech/Python', '~/Tech/PostgreSQL', '~/Tech/Ruby', '~/Tech/HTML5']

* An option to update hardlinks if and only if the original file has changed

## LEGAL DISCLAIMER

Please use at your own risk. I guarantee nothing about this program.

