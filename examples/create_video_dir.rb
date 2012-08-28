require_relative '../lib/mediatype_directory/mediatype_directory'

md = MediatypeDirectory.new({
      extensions: [".flv",".mov",".mpg",'.mp4'],
      directory_tree: '/home/jimmy/Tech/Ruby',
      mediatype_dirname: '~/Tech/Docs2/Videos',
      linktype: 'hard'
    })

md.create_directory
