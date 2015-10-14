# Parts of this inspired by
# https://github.com/Operational-Transformation/ot.js/blob/c4f27a/lib/codemirror-adapter.js
window.Collaborate.Adapters.AceAdapter = class AceAdapter
  constructor: (@collaborativeAttribute, @editor) ->
    @collaborativeAttribute.on 'remoteOperation', @applyRemoteOperation

    @session = @editor.getSession()
    @document = @session.getDocument()

    @document.on 'change', @textChange

  # Called when the textarea has changed.
  #
  # We want to generate an operation that describes the change, and send it off
  # to our server.
  textChange: (e) =>
    startIndex = @document.positionToIndex(e.start)
    endIndex = @document.positionToIndex(e.end)
    documentLength = @document.getValue().length
    endRetain = documentLength - endIndex

    changedText = e.lines.join('\n')

    operation = new ot.TextOperation()

    switch e.action
      when 'insert'
        operation.retain(startIndex).insert(changedText).retain(endRetain)
      when 'remove'
        operation.retain(startIndex).delete(changedText).retain(endRetain)

    @collaborativeAttribute.localOperation(operation)

  applyRemoteOperation: (operation) =>
    Range = ace.require('ace/range')

    ops = operation.ops

    cursor = 0

    for op in ops
      if ot.TextOperation.isRetain(op)
        cursor += op
      else if ot.TextOperation.isInsert(op)
        position = @document.indexToPosition(cursor)

        @session.insert(position, op)

        cursor += op.length
      else if ot.TextOperation.isDelete(op)
        startPosition = @document.indexToPosition(cursor)
        endPosition = @document.indexToPosition(cursor + op)
        deleteRange = new Range(startPosition.row, startPosition.column, endPosition.row, endPosition.column)

        @session.remove(deleteRange)

        # Op is negative
        cursor += op
