#= require ace/ace
#= require cable
#= require collaborate
#= require collaborate/adapters/ace_adapter

return unless documentId?

cable = Cable.createConsumer "ws://localhost:28080"

collaborate = new Collaborate(cable, 'DocumentChannel', documentId)

collaborativeTitle = collaborate.addAttribute('title')
new Collaborate.Adapters.TextAreaAdapter(collaborativeTitle, '#title')

bodyEditor = ace.edit('body')

collaborativeBody = collaborate.addAttribute('body')
new Collaborate.Adapters.AceAdapter(collaborativeBody, bodyEditor)
