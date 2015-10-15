# Parts of this inspired by
# https://github.com/Operational-Transformation/ot.js/blob/c4f27a/lib/codemirror-adapter.js
window.Collaborate.Adapters.AceAdapter = class AceAdapter
  applyingRemoteOperation: false

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
    # Ace fires a change event when we insert or delete text as well.
    return if @applyingRemoteOperation

    startIndex = @document.positionToIndex(e.start)
    endIndex = @document.positionToIndex(e.end)
    documentLength = @document.getValue().length
    changedText = e.lines.join('\n')

    endRetain = documentLength - endIndex

    operation = new ot.TextOperation()

    switch e.action
      when 'insert'
        operation.retain(startIndex).insert(changedText).retain(endRetain)
      when 'remove'
        removedLength = changedText.length
        operation.retain(startIndex).delete(removedLength).retain(endRetain + removedLength)

    @collaborativeAttribute.localOperation(operation)

  applyRemoteOperation: (operation) =>
    Range = ace.require('ace/range').Range

    ops = operation.ops

    cursor = 0

    @applyingRemoteOperation = true

    for op in ops
      if ot.TextOperation.isRetain(op)
        cursor += op
      else if ot.TextOperation.isInsert(op)
        position = @document.indexToPosition(cursor)

        @session.insert(position, op)

        cursor += op.length
      else if ot.TextOperation.isDelete(op)
        startPosition = @document.indexToPosition(cursor)
        # op is the negative number of places to delete
        endPosition = @document.indexToPosition(cursor - op)

        deleteRange = new Range(startPosition.row, startPosition.column, endPosition.row, endPosition.column)

        @session.remove(deleteRange)

        # Op is negative
        cursor += op

    @applyingRemoteOperation = false
