require_relative '../lib/mediatype_directory/mediatype_directory'

md = MediatypeDirectory.new({
      extensions: ['.pdf'],
      directory_tree: '/home/jimmy/Tech/Ruby/DOCUMENTATION',
      mediatype_dirname: '~/Tech/Docs2/PDFs',
      linktype: 'hard'
    })

md.create_directory
